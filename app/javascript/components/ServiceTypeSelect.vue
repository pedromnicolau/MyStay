<template>
  <div>
    <label class="block text-sm font-medium text-gray-700 mb-1">{{ label }}</label>
    <SelectWithFilter
      :options="options"
      :modelValue="modelValue"
      @update:modelValue="val => $emit('update:modelValue', val)"
    />
  </div>
</template>

<script>
import SelectWithFilter from './SelectWithFilter.vue'

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
    label: {
      type: String,
      default: 'Tipo de Serviço'
    }
  },
  emits: ['update:modelValue']
}
</script>
