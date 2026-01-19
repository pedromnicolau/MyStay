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
        <svg class="w-5 h-5" viewBox="0 0 32 32" fill="currentColor" aria-hidden="true">
          <path d="M19.11 17.36c-.28-.14-1.64-.81-1.9-.9-.26-.1-.45-.14-.64.14-.19.28-.73.9-.9 1.08-.17.19-.33.21-.61.07-.28-.14-1.16-.43-2.21-1.37-.82-.73-1.37-1.63-1.53-1.91-.16-.28-.02-.43.12-.57.12-.12.28-.33.42-.5.14-.17.19-.28.28-.47.09-.19.05-.36-.02-.5-.07-.14-.64-1.53-.88-2.1-.23-.56-.47-.48-.64-.49-.17-.01-.36-.01-.55-.01-.19 0-.5.07-.76.36-.26.28-1 1-1 2.45 0 1.44 1.03 2.84 1.17 3.04.14.19 2.02 3.08 4.89 4.31.68.29 1.21.46 1.62.58.68.22 1.31.19 1.8.12.55-.08 1.64-.67 1.87-1.31.23-.64.23-1.19.16-1.31-.07-.12-.26-.19-.54-.33z"/>
          <path d="M26.73 5.27C24.24 2.79 21.21 1.5 18 1.5 9.99 1.5 3.5 7.99 3.5 16c0 2.56.67 5.06 1.94 7.27L3 31l7.91-2.38C13.06 29.89 15.49 30.5 18 30.5 26.01 30.5 32.5 24.01 32.5 16c0-3.21-1.29-6.24-3.77-8.73zM18 28.5c-2.29 0-4.52-.62-6.47-1.8l-.46-.27-4.7 1.41 1.45-4.57-.3-.47C6.3 20.3 5.5 18.18 5.5 16 5.5 9.1 11.1 3.5 18 3.5S30.5 9.1 30.5 16 24.9 28.5 18 28.5z"/>
        </svg>
      </a>
    </div>
    <SelectWithFilter
      :options="options"
      :modelValue="modelValue"
      @update:modelValue="val => $emit('update:modelValue', val)"
    />
  </div>
</template>

<script>
import SelectWithFilter from './SelectWithFilter.vue'
import { useBrazilianMasks } from '../composables/useBrazilianMasks.js'

const { getWhatsAppLink } = useBrazilianMasks()

export default {
  components: { SelectWithFilter },
  props: {
    modelValue: {
      type: String,
      default: ''
    },
    options: {
      type: Array,
      required: true
    },
    selectedPerson: {
      type: Object,
      default: null
    },
    label: {
      type: String,
      required: true
    }
  },
  emits: ['update:modelValue'],
  computed: {
    whatsAppLink() {
      const phone = this.selectedPerson && this.selectedPerson.phone
      if (!phone) return null
      return getWhatsAppLink(phone)
    }
  }
}
</script>
