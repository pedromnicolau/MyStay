<template>
  <div
    v-if="isOpen"
    class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
    @click.self="$emit('close')"
  >
    <div class="bg-white rounded-lg shadow-xl max-w-md w-full p-6">
      <div class="flex justify-between items-center mb-4">
        <h3 class="text-lg font-semibold text-gray-900">Novo Tipo de Serviço</h3>
        <button @click="$emit('close')" class="text-gray-400 hover:text-gray-600">
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>

      <form @submit.prevent="handleSave" class="space-y-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Nome *</label>
          <input
            v-model="form.name"
            type="text"
            required
            autofocus
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
            placeholder="Ex: Limpeza Pesada, Manutenção..."
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Descrição</label>
          <textarea
            v-model="form.description"
            rows="3"
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
            placeholder="Descrição opcional do tipo de serviço"
          ></textarea>
        </div>

        <div v-if="error" class="text-red-600 text-sm">
          {{ error }}
        </div>

        <div class="flex justify-end space-x-3">
          <button
            type="button"
            @click="$emit('close')"
            class="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition"
          >
            Cancelar
          </button>
          <button
            type="submit"
            :disabled="loading"
            class="px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition disabled:opacity-50"
          >
            {{ loading ? 'Salvando...' : 'Salvar' }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  props: {
    isOpen: {
      type: Boolean,
      default: false
    }
  },

  emits: ['close', 'save'],

  data() {
    return {
      form: {
        name: '',
        description: ''
      },
      loading: false,
      error: ''
    }
  },

  watch: {
    isOpen(newVal) {
      if (newVal) {
        this.form = {
          name: '',
          description: ''
        }
        this.error = ''
      }
    }
  },

  methods: {
    async handleSave() {
      this.loading = true
      this.error = ''

      try {
        const token = localStorage.getItem('token')
        const response = await axios.post(
          '/api/v1/service_types',
          { service_type: this.form },
          { headers: { Authorization: `Bearer ${token}` } }
        )

        this.$emit('save', response.data)
        this.$emit('close')
      } catch (err) {
        this.error = err.response?.data?.errors?.join(', ') || 'Erro ao criar tipo de serviço'
      } finally {
        this.loading = false
      }
    }
  }
}
</script>
