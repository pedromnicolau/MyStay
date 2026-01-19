<template>
  <div v-if="isOpen" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
    <div class="bg-white rounded-lg shadow-xl max-w-sm w-full mx-4">
      <!-- Header -->
      <div class="px-6 py-4 border-b border-gray-200">
        <h3 class="text-lg font-semibold text-gray-900">{{ title }}</h3>
      </div>

      <!-- Body -->
      <div class="px-6 py-4">
        <p class="text-gray-600 mb-4">{{ message }}</p>
        
        <!-- Extra content slot -->
        <slot></slot>

        <!-- Details if provided -->
        <div v-if="details" class="mt-4 bg-gray-50 p-4 rounded border border-gray-200">
          <div class="text-sm text-gray-700" v-html="details"></div>
        </div>
      </div>

      <!-- Footer with Actions -->
      <div class="px-6 py-4 bg-gray-50 border-t border-gray-200 flex gap-3 justify-end">
        <button
          @click="onCancel"
          :disabled="loading"
          class="px-4 py-2 text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {{ cancelLabel }}
        </button>
        
        <button
          @click="onConfirm"
          :disabled="loading"
          :class="[
            'px-4 py-2 text-white rounded-lg font-medium transition disabled:opacity-50 disabled:cursor-not-allowed',
            `bg-${confirmButtonColor}-600 hover:bg-${confirmButtonColor}-700`
          ]"
        >
          <span v-if="!loading">{{ confirmLabel }}</span>
          <span v-else class="inline-flex items-center">
            <svg class="animate-spin -ml-1 mr-2 h-4 w-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            Processando...
          </span>
        </button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ConfirmationModal',
  props: {
    isOpen: {
      type: Boolean,
      required: true
    },
    title: {
      type: String,
      required: true
    },
    message: {
      type: String,
      required: true
    },
    details: {
      type: String,
      default: null
    },
    confirmLabel: {
      type: String,
      default: 'Confirmar'
    },
    cancelLabel: {
      type: String,
      default: 'Cancelar'
    },
    confirmButtonColor: {
      type: String,
      default: 'red',
      validator: (value) => ['red', 'blue', 'green', 'yellow', 'purple', 'orange'].includes(value)
    },
    loading: {
      type: Boolean,
      default: false
    }
  },
  emits: ['confirm', 'cancel'],
  methods: {
    onConfirm() {
      this.$emit('confirm')
    },
    onCancel() {
      this.$emit('cancel')
    }
  }
}
</script>
