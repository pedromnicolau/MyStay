<template>
  <div class="min-h-screen bg-gray-50">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div class="mb-6 flex justify-between items-center">
        <h1 class="text-3xl font-bold text-gray-900">{{ title }}</h1>
        <button
          @click="openCreateModal"
          class="bg-indigo-600 text-white px-6 py-2.5 rounded-lg hover:bg-indigo-700 transition flex items-center space-x-2 shadow-sm"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
          </svg>
          <span>Novo</span>
        </button>
      </div>

      <div v-if="loading" class="flex justify-center items-center h-64">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600"></div>
      </div>

      <div v-else-if="error" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
        {{ error }}
      </div>

      <div v-else class="bg-white rounded-lg shadow-sm overflow-hidden">
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th
                  v-for="column in columns"
                  :key="column.key"
                  class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                >
                  {{ column.label }}
                </th>
                <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Ações
                </th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <template v-if="validItems.length === 0">
                <tr>
                  <td :colspan="columns.length + 1" class="px-6 py-12 text-center text-gray-500">
                    Nenhum registro encontrado
                  </td>
                </tr>
              </template>
              <template v-else>
                <tr v-for="item in validItems" :key="item.id" class="hover:bg-gray-50 transition">
                  <td
                    v-for="column in columns"
                    :key="column.key"
                    class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"
                  >
                    <template v-if="column.format">
                      {{ column.format(item[column.key], item) }}
                    </template>
                    <template v-else>
                      {{ item[column.key] || '-' }}
                    </template>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <button
                      @click="editItem(item)"
                      class="text-indigo-600 hover:text-indigo-900 mr-4"
                    >
                      <svg class="w-5 h-5 inline" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                      </svg>
                    </button>
                    <button
                      @click="confirmDelete(item)"
                      class="text-red-600 hover:text-red-900"
                    >
                      <svg class="w-5 h-5 inline" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                      </svg>
                    </button>
                  </td>
                </tr>
              </template>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <div
      v-if="isModalOpen"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
      @click.self="closeModal"
    >
      <div class="bg-white rounded-lg shadow-xl max-w-2xl w-full max-h-[90vh] flex flex-col">
        <div class="px-6 py-4 border-b border-gray-200 flex justify-between items-center flex-shrink-0">
          <h2 class="text-xl font-semibold text-gray-900">
            {{ editingItem ? 'Editar' : 'Novo' }} {{ singularTitle }}
          </h2>
          <button @click="closeModal" class="text-gray-400 hover:text-gray-600">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <form @submit.prevent="saveItem" class="flex flex-col flex-1 min-h-0">
          <div class="px-6 py-4 overflow-y-auto flex-1">
            <div v-if="formErrors.general" class="mb-4 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
              {{ formErrors.general }}
            </div>
            
            <slot name="form" :form="form" :errors="formErrors"></slot>
          </div>

          <div class="px-6 py-4 border-t border-gray-200 flex justify-between items-center flex-shrink-0 bg-gray-50">
            <button
              v-if="editingItem"
              type="button"
              @click="confirmDelete(editingItem)"
              class="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition disabled:opacity-50"
            >
              Excluir
            </button>
            <div v-else></div>
            <div class="flex space-x-3">
              <button
                type="button"
                @click="closeModal"
                class="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition"
              >
                Cancelar
              </button>
              <button
                type="submit"
                :disabled="saving"
                class="px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition disabled:opacity-50"
              >
                {{ saving ? 'Salvando...' : 'Salvar' }}
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>

    <div
      v-if="deleteConfirmItem"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
      @click.self="closeDeleteModal"
    >
      <div class="bg-white rounded-lg shadow-xl max-w-2xl w-full p-6 max-h-[90vh] overflow-y-auto">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">Confirmar Exclusão</h3>
        
        <div v-if="!deleteError">
          <p class="text-gray-600 mb-6">
            Tem certeza que deseja excluir este registro? Esta ação não pode ser desfeita.
          </p>
        </div>

        <div v-else class="mb-6">
          <div class="bg-red-50 border border-red-200 rounded-lg p-4 mb-4">
            <div class="flex items-start">
              <svg class="w-5 h-5 text-red-600 mt-0.5 mr-3 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"/>
              </svg>
              <div class="flex-1">
                <h4 class="text-red-800 font-semibold mb-1">{{ deleteError }}</h4>
                <p class="text-red-700 text-sm">{{ deleteErrorMessage }}</p>
              </div>
            </div>
          </div>

          <div v-if="relatedStays && relatedStays.length > 0" class="space-y-2">
            <p class="text-sm font-semibold text-gray-700 mb-2">
              Estadias relacionadas ({{ relatedStays.length }}):
            </p>
            <div class="bg-gray-50 rounded-lg divide-y divide-gray-200">
              <div
                v-for="stay in relatedStays"
                :key="stay.id"
                class="p-3 hover:bg-gray-100 transition cursor-pointer"
                @click="goToStay(stay.id)"
              >
                <div class="flex items-center justify-between">
                  <div class="flex-1">
                    <p class="text-sm font-medium text-gray-900">{{ stay.guest_name }}</p>
                    <p class="text-xs text-gray-600">Reserva: {{ stay.booking_reference }}</p>
                    <p class="text-xs text-gray-500">
                      Check-in: {{ formatDate(stay.check_in_date) }} | Check-out: {{ formatDate(stay.check_out_date) }}
                    </p>
                  </div>
                  <svg class="w-5 h-5 text-indigo-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
                  </svg>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="flex justify-end space-x-3">
          <button
            @click="closeDeleteModal"
            class="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition"
          >
            {{ deleteError ? 'Fechar' : 'Cancelar' }}
          </button>
          <button
            v-if="!deleteError"
            @click="deleteItem"
            :disabled="deleting"
            class="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition disabled:opacity-50"
          >
            {{ deleting ? 'Excluindo...' : 'Excluir' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios'
import { navigateTo } from '../router.js'

export default {
  props: {
    title: {
      type: String,
      required: true
    },
    singularTitle: {
      type: String,
      required: true
    },
    apiEndpoint: {
      type: String,
      required: true
    },
    columns: {
      type: Array,
      required: true
    },
    formFields: {
      type: Object,
      required: true
    }
  },

  data() {
    return {
      items: [],
      loading: false,
      error: null,
      isModalOpen: false,
      editingItem: null,
      form: {},
      formErrors: {},
      saving: false,
      deleteConfirmItem: null,
      deleting: false,
      deleteError: null,
      deleteErrorMessage: null,
      relatedStays: []
    }
  },

  computed: {
    validItems() {
      if (!Array.isArray(this.items)) {
        return []
      }
      return this.items.filter(item => item && item.id)
    }
  },

  mounted() {
    this.loadItems()
  },

  methods: {
    async loadItems() {
      this.loading = true
      this.error = null

      try {
        const token = localStorage.getItem('token')
        const response = await axios.get(this.apiEndpoint, {
          headers: { Authorization: `Bearer ${token}` }
        })
        
        this.items = Array.isArray(response.data) ? response.data : []
      } catch (err) {
        this.error = err.response?.data?.error || 'Erro ao carregar os dados'
      } finally {
        this.loading = false
      }
    },

    openCreateModal() {
      this.editingItem = null
      this.form = { ...this.formFields }
      this.formErrors = {}
      this.isModalOpen = true
    },

    editItem(item) {
      this.editingItem = item
      this.form = { ...this.formFields, ...item }
      this.formErrors = {}
      this.isModalOpen = true
    },

    closeModal() {
      this.isModalOpen = false
      this.editingItem = null
      this.form = { ...this.formFields }
      this.formErrors = {}
    },

    async saveItem() {
      this.saving = true
      this.formErrors = {}

      try {
        const token = localStorage.getItem('token')
        const headers = { Authorization: `Bearer ${token}` }
        const resourceName = this.getResourceName()
        const baseEndpoint = this.apiEndpoint.split('?')[0]

        // Enviar apenas os campos definidos em formFields
        const cleanedForm = {}
        for (const key in this.formFields) {
          const value = this.form[key]
          // Incluir o campo se não for undefined (null e strings vazias são válidos)
          if (value !== undefined) {
            cleanedForm[key] = value
          }
        }

        if (this.editingItem) {
          await axios.put(`${baseEndpoint}/${this.editingItem.id}`, 
            { [resourceName]: cleanedForm },
            { headers }
          )
        } else {
          await axios.post(baseEndpoint,
            { [resourceName]: cleanedForm },
            { headers }
          )
        }

        this.closeModal()
        this.loadItems()
      } catch (err) {
        this.formErrors.general = err.response?.data?.errors?.join(', ') || 'Erro ao salvar'
      } finally {
        this.saving = false
      }
    },

    confirmDelete(item) {
      this.deleteConfirmItem = item
      this.deleteError = null
      this.deleteErrorMessage = null
      this.relatedStays = []
    },

    closeDeleteModal() {
      this.deleteConfirmItem = null
      this.deleteError = null
      this.deleteErrorMessage = null
      this.relatedStays = []
    },

    async deleteItem() {
      this.deleting = true
      this.error = null // Limpa erro anterior

      try {
        const token = localStorage.getItem('token')
        const baseEndpoint = this.apiEndpoint.split('?')[0]
        await axios.delete(`${baseEndpoint}/${this.deleteConfirmItem.id}`, {
          headers: { Authorization: `Bearer ${token}` }
        })

        this.closeDeleteModal()
        this.closeModal()
        this.loadItems()
      } catch (err) {
        console.log('Erro ao excluir:', err.response)
        // Verifica se é um erro de violação de chave estrangeira
        if (err.response?.status === 409) {
          console.log('Erro 409 detectado:', err.response.data)
          this.deleteError = err.response.data.error
          this.deleteErrorMessage = err.response.data.message
          this.relatedStays = err.response.data.related_stays || []
          // Não fecha o modal, apenas exibe o erro dentro dele
        } else {
          this.error = err.response?.data?.error || 'Erro ao excluir'
          this.closeDeleteModal()
        }
      } finally {
        this.deleting = false
      }
    },

    goToStay(stayId) {
      this.closeDeleteModal()
      navigateTo('bookings', { stayId })
    },

    formatDate(dateString) {
      if (!dateString) return ''
      const date = new Date(dateString)
      return date.toLocaleDateString('pt-BR')
    },

    getResourceName() {
      const endpoint = this.apiEndpoint.split('?')[0]
      const lastSegment = endpoint.split('/').pop()
      if (lastSegment === 'people') {
        return 'person'
      }
      if (lastSegment === 'properties') {
        return 'property'
      }
      return lastSegment.slice(0, -1)
    }
  }
}
</script>
