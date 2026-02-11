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
      <button
        v-if="!required && modelValue && !isOpen"
        @click="clearSelection"
        type="button"
        class="absolute right-3 top-2.5 text-gray-400 hover:text-gray-600"
      >
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
        </svg>
      </button>
      <div 
        v-if="isOpen" 
        class="absolute top-full left-0 right-0 mt-1 bg-white border border-gray-300 rounded-lg shadow-lg z-20 max-h-64 overflow-y-auto"
        @mousedown.prevent
      >
        <div
          v-if="!required"
          @mousedown.prevent="selectOption('')"
          :class="[
            'px-4 py-2 cursor-pointer text-gray-500 italic border-b border-gray-200',
            highlightedIndex === -1 ? 'bg-indigo-100' : 'hover:bg-indigo-50'
          ]"
        >
          Todos os imóveis
        </div>
        <div 
          v-for="(option, index) in filteredOptions"
          :key="option.value"
          @mousedown.prevent="selectOption(option.value)"
          :class="[
            'px-4 py-2 cursor-pointer text-gray-900',
            index === highlightedIndex ? 'bg-indigo-100' : 'hover:bg-indigo-50'
          ]"
        >
          {{ option.label }}
        </div>
        <div v-if="filteredOptions.length === 0 && !loading" class="px-4 py-2 text-gray-500">
          Nenhuma propriedade encontrada
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
      type: [String, Number],
      default: null
    },
    selectedProperty: {
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
    },
    required: {
      type: Boolean,
      default: false
    }
  },
  emits: ['update:modelValue'],
  data() {
    return {
      isOpen: false,
      filterText: '',
      properties: [],
      loading: false,
      highlightedIndex: -1,
      blurTimeout: null,
      searchTimeout: null,
      shouldMaintainFocus: false
    }
  },
  watch: {
    modelValue(newVal, oldVal) {
      if (newVal && newVal !== oldVal) {
        // Se não temos as propriedades carregadas ou a propriedade atual não está na lista, carregar
        if (!Array.isArray(this.properties) || this.properties.length === 0 || 
            !this.properties.find(p => String(p.id) === String(newVal))) {
          this.loadProperties()
        }
      }
    },
    properties(newVal) {
      // Se é obrigatório, as propriedades foram carregadas e não há valor selecionado, selecionar a primeira
      if (this.required && newVal && newVal.length > 0 && 
          (this.modelValue === null || this.modelValue === undefined || this.modelValue === '')) {
        this.$emit('update:modelValue', newVal[0].id)
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
    currentSelectedProperty() {
      // Priorizar modelValue sobre selectedProperty para permitir atualizações
      if (this.modelValue !== null && this.modelValue !== '' && Array.isArray(this.properties)) {
        const found = this.properties.find(p => String(p.id) === String(this.modelValue))
        if (found) return found
      }
      
      // Fallback para selectedProperty apenas se não houver modelValue
      if (this.selectedProperty && (!this.modelValue || this.modelValue === '')) {
        return this.selectedProperty
      }
      
      return null
    },
    
    displayValue() {
      if (this.isOpen) {
        return this.filterText
      }
      
      // Se não há valor selecionado e não é obrigatório, retornar vazio para mostrar o placeholder
      if (!this.modelValue || this.modelValue === '') {
        return ''
      }
      
      const property = this.currentSelectedProperty
      return property ? property.name : ''
    },
    
    filteredOptions() {
      if (!Array.isArray(this.properties)) {
        return []
      }

      // Não filtrar localmente - a filtragem é feita no servidor
      const filtered = this.properties.map(p => ({ 
        value: p.id, 
        label: p.name, 
        data: p 
      }))

      return filtered
    }
  },
  methods: {
    async loadProperties(searchTerm = null) {
      if (this.loading) return
      
      this.loading = true
      try {
        const { getProperties } = useApi()
        const { data, error } = await getProperties(searchTerm)
        
        if (!error && data) {
          this.properties = data.data || data
        }
      } catch (err) {
        console.error('Error loading properties:', err)
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
      this.loadProperties()
    },
    
    closeDropdown() {
      // Se é obrigatório, não há valor selecionado e há propriedades, selecionar a primeira
      if (this.required && 
          (this.modelValue === null || this.modelValue === undefined || this.modelValue === '') 
          && this.properties.length > 0) {
        this.$emit('update:modelValue', this.properties[0].id)
      }
      
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
        this.loadProperties(searchTerm || null)
      }, 300)
    },
    
    selectOption(value) {
      this.$emit('update:modelValue', value)
      this.closeDropdown()
      this.$refs.inputRef?.blur()
    },
    
    clearSelection() {
      this.$emit('update:modelValue', '')
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
    // Carregar propriedades se já temos um modelValue OU se é obrigatório
    if (this.modelValue || this.required) {
      this.loadProperties()
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
