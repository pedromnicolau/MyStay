<template>
  <div>
    <div class="flex items-center justify-between mb-1">
      <label class="block text-sm font-medium text-gray-700">{{ label }}</label>
      <a
        v-if="whatsAppLink"
        :href="whatsAppLink"
        target="_blank"
        rel="noopener"
        class="text-gray-400 hover:text-emerald-600 transition"
        :title="`WhatsApp de ${selectedPerson?.name || 'Contato'}`"
      >
        <i class="fab fa-whatsapp text-lg"></i>
      </a>
    </div>
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
            index === highlightedIndex ? 'bg-indigo-100' : 'hover:bg-indigo-50'
          ]"
        >
          {{ option.label }}
        </div>
        <div v-if="filteredOptions.length === 0 && !loading" class="px-4 py-2 text-gray-500">
          Nenhuma opção encontrada
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
import { useBrazilianMasks } from '../composables/useBrazilianMasks.js'
import { useApi } from '../composables/useApi.js'

const { getWhatsAppLink } = useBrazilianMasks()

export default {
  props: {
    modelValue: {
      type: String,
      default: ''
    },
    selectedPerson: {
      type: Object,
      default: null
    },
    label: {
      type: String,
      required: true
    },
    role: {
      type: String,
      required: true,
      validator: (value) => ['customer', 'agent', 'provider'].includes(value)
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
      people: [],
      loading: false,
      highlightedIndex: -1,
      blurTimeout: null,
      searchTimeout: null,
      shouldMaintainFocus: false
    }
  },
  watch: {
    // Recarregar dados quando o modelValue mudar para um valor numérico (nova pessoa criada)
    modelValue(newVal, oldVal) {
      if (newVal && newVal !== 'new' && newVal !== oldVal) {
        // Recarregar dados após um delay para dar tempo do backend processar
        setTimeout(() => {
          this.loadPeople()
        }, 500)
      }
    },
    // Adicionar/remover listener quando dropdown abre/fecha
    isOpen(newVal) {
      if (newVal) {
        // Aguardar próximo tick para não capturar o clique que abriu
        this.$nextTick(() => {
          document.addEventListener('click', this.handleClickOutside)
        })
      } else {
        document.removeEventListener('click', this.handleClickOutside)
      }
    }
  },
  computed: {
    whatsAppLink() {
      const person = this.currentSelectedPerson
      const phone = person && person.phone
      if (!phone) return null
      return getWhatsAppLink(phone)
    },
    
    currentSelectedPerson() {
      // Priorizar selectedPerson prop (quando editando)
      if (this.selectedPerson) {
        return this.selectedPerson
      }
      
      // Buscar na lista carregada pelo modelValue
      if (this.modelValue && this.modelValue !== 'new' && Array.isArray(this.people)) {
        return this.people.find(p => String(p.id) === String(this.modelValue))
      }
      
      return null
    },
    
    displayValue() {
      if (this.isOpen) {
        return this.filterText
      }
      
      const person = this.currentSelectedPerson
      return person ? person.name : ''
    },
    filteredOptions() {
      const newOption = { value: 'new', label: this.getNewOptionLabel() }
      
      if (!Array.isArray(this.people)) {
        return [newOption]
      }

      // Não filtrar localmente - a filtragem é feita no servidor
      const filtered = this.people
        .filter(p => !p.blocked)
        .map(p => ({ value: String(p.id), label: p.name, data: p }))

      return [newOption, ...filtered]
    }
  },
  methods: {
    getNewOptionLabel() {
      const labels = {
        customer: '+ Novo Hóspede',
        agent: '+ Novo Corretor',
        provider: '+ Novo Prestador'
      }
      return labels[this.role] || '+ Novo'
    },
    async loadPeople(searchTerm = null) {
      if (this.loading) return
      
      this.loading = true
      try {
        const { getPeople } = useApi()
        const { data, error } = await getPeople(this.role, searchTerm)
        
        if (!error && data) {
          // Se data tem uma propriedade data (paginada), usar ela
          this.people = data.data || data
        }
      } catch (err) {
        console.error('Error loading people:', err)
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
      // Abrir dropdown ao clicar se ainda não estiver aberto
      if (!this.isOpen) {
        this.isOpen = true
        this.highlightedIndex = -1
        this.loadPeople()
      }
    },
    
    async handleFocus() {
      // Limpar qualquer timeout de blur pendente
      if (this.blurTimeout) {
        clearTimeout(this.blurTimeout)
        this.blurTimeout = null
      }
      
      // Sempre recarregar dados ao focar no campo
      if (!this.isOpen) {
        this.isOpen = true
        this.highlightedIndex = -1
        await this.loadPeople()
      }
    },
    
    handleInput(event) {
      this.filterText = event.target.value
      this.isOpen = true
      this.highlightedIndex = -1
      this.shouldMaintainFocus = true
      
      // Limpar timeout anterior
      if (this.searchTimeout) {
        clearTimeout(this.searchTimeout)
      }
      
      // Buscar no servidor após 300ms de inatividade
      this.searchTimeout = setTimeout(() => {
        const searchTerm = this.filterText.trim()
        this.loadPeople(searchTerm || null)
      }, 300)
    },
    
    selectOption(value) {
      // Limpar timeout de blur se existir
      if (this.blurTimeout) {
        clearTimeout(this.blurTimeout)
        this.blurTimeout = null
      }
      
      this.$emit('update:modelValue', value)
      this.closeDropdown()
    },
    
    closeDropdown() {
      this.isOpen = false
      this.filterText = ''
      this.highlightedIndex = -1
      if (this.blurTimeout) {
        clearTimeout(this.blurTimeout)
        this.blurTimeout = null
      }
    },
    
    handleClickOutside(event) {
      // Verificar se o clique foi no input ou no dropdown
      const input = this.$refs.inputRef
      const dropdown = this.$el?.querySelector('.max-h-64')?.parentElement
      
      const clickedInput = input && input.contains(event.target)
      const clickedDropdown = dropdown && dropdown.contains(event.target)
      
      // Fechar apenas se clicou fora do input E do dropdown
      if (!clickedInput && !clickedDropdown) {
        this.closeDropdown()
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
        this.scrollToHighlighted()
      }
    },
    
    highlightPrevious() {
      if (this.highlightedIndex > 0) {
        this.highlightedIndex--
        this.scrollToHighlighted()
      }
    },
    
    scrollToHighlighted() {
      this.$nextTick(() => {
        const dropdown = this.$el.querySelector('.max-h-64')
        const highlighted = dropdown?.children[this.highlightedIndex]
        if (highlighted) {
          highlighted.scrollIntoView({ block: 'nearest' })
        }
      })
    },
    
    // Método público para forçar reload dos dados (útil após criar nova pessoa)
    async forceReload() {
      await this.loadPeople()
    }
  },
  
  beforeUnmount() {
    // Limpar timeouts ao destruir componente
    if (this.blurTimeout) {
      clearTimeout(this.blurTimeout)
    }
    if (this.searchTimeout) {
      clearTimeout(this.searchTimeout)
    }
    // Remover listener de clique
    document.removeEventListener('click', this.handleClickOutside)
  }
}
</script>
