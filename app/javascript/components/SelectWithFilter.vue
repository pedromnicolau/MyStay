<template>
  <div class="relative">
    <input
      type="text"
      :value="displayValue"
      @click="openFilter"
      @input="handleFilterInput"
      @blur="closeAfterDelay"
      @keydown.escape="isOpen = false"
      @keydown.enter="selectFirstOption"
      placeholder="Selecione ou digite para filtrar..."
      class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
    />
    <div 
      v-if="isOpen" 
      class="absolute top-full left-0 right-0 mt-1 bg-white border border-gray-300 rounded-lg shadow-lg z-20 max-h-48 overflow-y-auto"
    >
      <div 
        v-for="option in filteredOptions"
        :key="option.value"
        @click="selectOption(option.value)"
        class="px-4 py-2 hover:bg-indigo-50 cursor-pointer text-gray-900"
      >
        {{ option.label }}
      </div>
      <div v-if="filteredOptions.length === 0" class="px-4 py-2 text-gray-500">
        Nenhuma opção encontrada
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    modelValue: {
      type: String,
      default: ''
    },
    options: {
      type: Array,
      required: true
    }
  },

  emits: ['update:modelValue'],

  data() {
    return {
      isOpen: false,
      filterText: ''
    }
  },

  computed: {
    displayValue() {
      if (this.isOpen) {
        return this.filterText
      }
      const selected = this.options.find(opt => opt.value === this.modelValue)
      return selected ? selected.label : ''
    },

    filteredOptions() {
      const opts = Array.isArray(this.options) ? this.options : []
      const newOption = opts.find(o => o && String(o.value) === 'new')
      const others = opts.filter(o => !o || String(o.value) !== 'new')

      let filteredOthers = others
      if (this.filterText) {
        const searchLower = this.filterText.toLowerCase()
        filteredOthers = others.filter(opt => {
          const label = (opt.label || '').toString().toLowerCase()
          const value = (opt.value || '').toString().toLowerCase()
          return label.includes(searchLower) || value.includes(searchLower)
        })
      }

      const result = []
      if (newOption) result.push(newOption)
      return result.concat(filteredOthers)
    }
  },

  methods: {
    openFilter() {
      this.isOpen = true
      this.$nextTick(() => {
        this.$el.querySelector('input').focus()
      })
    },

    handleFilterInput(event) {
      this.filterText = event.target.value
      this.isOpen = true
    },

    selectOption(value) {
      this.$emit('update:modelValue', value)
      this.isOpen = false
      this.filterText = ''
    },

    selectFirstOption() {
      if (this.filteredOptions.length > 0) {
        this.selectOption(this.filteredOptions[0].value)
      }
    },

    closeAfterDelay() {
      setTimeout(() => {
        if (!this.isOpen) return
        this.isOpen = false
        this.filterText = ''
      }, 200)
    }
  }
}
</script>
