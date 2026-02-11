<template>
  <div>
    <label v-if="label" class="block text-sm font-medium text-gray-700 mb-1">{{ label }}</label>
    <div class="relative">
      <input
        ref="inputRef"
        type="text"
        :value="displayValue"
        @mousedown="handleMouseDown"
        @focus="handleFocus"
        @input="handleInput"
        @keydown.escape="closeDropdown"
        @keydown.enter.prevent="selectFirstOption"
        @keydown.arrow-down.prevent="highlightNext"
        @keydown.arrow-up.prevent="highlightPrevious"
        :placeholder="placeholder"
        class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
        :disabled="loading"
      />
      <div v-if="loading" class="absolute right-3 top-2.5">
        <div class="animate-spin rounded-full h-5 w-5 border-b-2 border-indigo-600"></div>
      </div>
      <div 
        v-if="isOpen" 
        class="absolute top-full left-0 right-0 mt-1 bg-white border border-gray-300 rounded-lg shadow-lg z-20 max-h-64 overflow-y-auto"
        @mousedown.prevent
      >
        <div 
          v-for="(option, index) in filteredOptions"
          :key="option.value"
          @mousedown.prevent="selectOption(option.value)"
          :class="[
            'px-4 py-2 cursor-pointer text-gray-900',
            index === highlightedIndex ? 'bg-indigo-100' : 'hover:bg-indigo-50',
            option.value === 'new' ? 'border-b border-gray-200 font-medium text-indigo-600' : ''
          ]"
        >
          {{ option.label }}
        </div>
        <div v-if="filteredOptions.length === 1 && filteredOptions[0].value === 'new' && !loading" class="px-4 py-2 text-gray-500">
          Nenhum tipo de serviço encontrado
        </div>
        <div v-if="loading" class="px-4 py-2 text-gray-500 flex items-center">
          <div class="animate-spin rounded-full h-4 w-4 border-b-2 border-indigo-600 mr-2"></div>
          Carregando...
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { useApi } from '../composables/useApi.js'

export default {
  props: {
    modelValue: {
      type: String,
      default: ''
    },
    selectedServiceType: {
      type: Object,
      default: null
    },
    label: {
      type: String,
      default: ''
    },
    placeholder: {
      type: String,
      default: 'Selecione ou digite para filtrar...'
    }
  },
  emits: ['update:modelValue'],
  data() {
    return {
      isOpen: false,
      filterText: '',
      serviceTypes: [],
      loading: false,
      highlightedIndex: -1,
      blurTimeout: null,
      searchTimeout: null,
      shouldMaintainFocus: false
    }
  },
  watch: {
    modelValue(newVal, oldVal) {
      if (newVal && newVal !== 'new' && newVal !== oldVal) {
        // Se não temos os tipos de serviço carregados ou o tipo atual não está na lista, carregar
        if (!Array.isArray(this.serviceTypes) || this.serviceTypes.length === 0 || 
            !this.serviceTypes.find(st => String(st.id) === String(newVal))) {
          this.loadServiceTypes()
        }
      }
    },
    isOpen(newVal) {
      if (newVal) {
        this.$nextTick(() => {
          document.addEventListener('click', this.handleClickOutside)
        })
      } else {
        document.removeEventListener('click', this.handleClickOutside)
      }
    }
  },
  computed: {
    currentSelectedServiceType() {
      // Se temos um modelValue válido, tentar encontrar no array carregado
      if (this.modelValue && this.modelValue !== 'new' && Array.isArray(this.serviceTypes)) {
        const found = this.serviceTypes.find(st => String(st.id) === String(this.modelValue))
        if (found) return found
      }
      
      // Se não encontrou no array mas temos selectedServiceType prop e o ID coincide, usar o prop
      if (this.selectedServiceType && this.modelValue && 
          String(this.selectedServiceType.id) === String(this.modelValue)) {
        return this.selectedServiceType
      }
      
      // Fallback para selectedServiceType apenas se não houver modelValue válido
      if (this.selectedServiceType && (!this.modelValue || this.modelValue === '' || this.modelValue === 'new')) {
        return this.selectedServiceType
      }
      
      return null
    },
    
    displayValue() {
      if (this.isOpen) {
        return this.filterText
      }
      
      const serviceType = this.currentSelectedServiceType
      return serviceType ? serviceType.name : ''
    },
    
    filteredOptions() {
      const newOption = { value: 'new', label: '+ Novo Tipo de Serviço' }
      
      if (!Array.isArray(this.serviceTypes)) {
        return [newOption]
      }

      // Não filtrar localmente - a filtragem é feita no servidor
      const filtered = this.serviceTypes.map(st => ({ 
        value: String(st.id), 
        label: st.name, 
        data: st 
      }))

      return [newOption, ...filtered]
    }
  },
  methods: {
    async loadServiceTypes(searchTerm = null) {
      if (this.loading) return
      
      this.loading = true
      try {
        const { getServiceTypes } = useApi()
        const { data, error } = await getServiceTypes(searchTerm)
        
        if (!error && data) {
          // Se data tem uma propriedade data (paginada), usar ela
          this.serviceTypes = data.data || data
        }
      } catch (err) {
        console.error('Error loading service types:', err)
      } finally {
        this.loading = false
        
        // Restaurar foco se necessário
        if (this.shouldMaintainFocus && this.$refs.inputRef) {
          this.$nextTick(() => {
            this.$refs.inputRef.focus()
            this.shouldMaintainFocus = false
          })
        }
      }
    },
    
    handleMouseDown(event) {
      if (this.isOpen) {
        return
      }
      
      this.openDropdown()
    },
    
    handleFocus() {
      if (!this.isOpen) {
        this.openDropdown()
      }
    },
    
    openDropdown() {
      this.isOpen = true
      this.filterText = ''
      this.highlightedIndex = -1
      this.loadServiceTypes()
    },
    
    closeDropdown() {
      this.isOpen = false
      this.filterText = ''
      this.highlightedIndex = -1
    },
    
    handleInput(event) {
      this.filterText = event.target.value
      this.highlightedIndex = -1
      this.shouldMaintainFocus = true
      
      // Limpar timeout anterior
      if (this.searchTimeout) {
        clearTimeout(this.searchTimeout)
      }
      
      // Buscar no servidor após 300ms de inatividade
      this.searchTimeout = setTimeout(() => {
        const searchTerm = this.filterText.trim()
        this.loadServiceTypes(searchTerm || null)
      }, 300)
    },
    
    selectOption(value) {
      this.$emit('update:modelValue', value)
      if (value !== 'new') {
        this.closeDropdown()
        this.$refs.inputRef?.blur()
      }
    },
    
    selectFirstOption() {
      if (this.filteredOptions.length > 0) {
        this.selectOption(this.filteredOptions[0].value)
      }
    },
    
    highlightNext() {
      if (this.highlightedIndex < this.filteredOptions.length - 1) {
        this.highlightedIndex++
      }
    },
    
    highlightPrevious() {
      if (this.highlightedIndex > 0) {
        this.highlightedIndex--
      }
    },
    
    handleClickOutside(event) {
      const el = this.$el
      if (el && !el.contains(event.target)) {
        this.closeDropdown()
      }
    }
  },
  
  mounted() {
    // Carregar tipos de serviço se já temos um modelValue
    if (this.modelValue && this.modelValue !== 'new') {
      this.loadServiceTypes()
    }
  },
  
  beforeUnmount() {
    if (this.searchTimeout) {
      clearTimeout(this.searchTimeout)
    }
    document.removeEventListener('click', this.handleClickOutside)
  }
}
</script>
