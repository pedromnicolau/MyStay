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
