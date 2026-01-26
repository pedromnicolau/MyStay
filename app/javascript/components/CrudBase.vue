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
                <tr
                  v-for="item in validItems"
                  :key="item.id"
                  :class="['transition', item.blocked ? 'bg-red-50 hover:bg-red-50' : 'hover:bg-gray-50']"
                >
                  <td
                    v-for="column in columns"
                    :key="column.key"
                    class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"
                  >
                    <template v-if="column.key === 'profile_image'">
                      <div class="flex items-center">
                        <div 
                          v-if="item[column.key]"
                          class="w-10 h-10 rounded-full overflow-hidden bg-gradient-to-br from-indigo-100 to-indigo-200 border-2 border-indigo-300 flex items-center justify-center flex-shrink-0"
                        >
                          <img 
                            :src="item[column.key]" 
                            :alt="item.name || 'Foto'"
                            class="w-full h-full object-cover"
                            @error="$event.target.style.display='none'"
                          />
                        </div>
                        <span v-else class="text-gray-400 text-xs">Sem foto</span>
                      </div>
                    </template>
                    <template v-else-if="column.format">
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
                <p class="text-red-700 text-sm mb-3">{{ deleteErrorMessage }}</p>
                <div class="bg-white rounded-md p-3 border border-red-100">
                  <p class="text-sm text-gray-700">
                    <strong class="text-red-700">💡 Solução rápida:</strong> Use o botão de lixeira para excluir as locações diretamente, ou clique no nome para editá-las.
                  </p>
                </div>
              </div>
            </div>
          </div>

          <div v-if="relatedStays && relatedStays.length > 0" class="space-y-2">
            <p class="text-sm font-semibold text-gray-700 mb-2">
              {{ relatedStays[0]?.is_cleaning !== undefined ? 'Locações' : 'Estadias' }} relacionadas ({{ relatedStays.length }}):
            </p>
            <div class="bg-gray-50 rounded-lg divide-y divide-gray-200">
              <div
                v-for="stay in relatedStays"
                :key="stay.id"
                class="p-3 group"
              >
                <div class="flex items-center justify-between gap-3">
                  <div 
                    class="flex-1 cursor-pointer hover:opacity-75 transition"
                    @click="goToStay(stay.id)"
                  >
                    <div class="flex items-center gap-2 mb-1">
                      <p class="text-sm font-medium text-gray-900">{{ stay.guest_name }}</p>
                      <span
                        v-if="stay.is_cleaning"
                        class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-amber-100 text-amber-800"
                      >
                        Faxina
                      </span>
                    </div>
                    <p class="text-xs text-gray-600" v-if="stay.booking_reference">
                      Reserva: {{ stay.booking_reference }}
                    </p>
                    <p class="text-xs text-gray-500">
                      Check-in: {{ formatDate(stay.check_in_date) }} | Check-out: {{ formatDate(stay.check_out_date) }}
                    </p>
                  </div>
                  <div class="flex items-center gap-2">
                    <button
                      @click="openDeleteRelatedStayConfirm(stay)"
                      :disabled="deletingStayId === stay.id"
                      class="p-2 text-red-600 hover:bg-red-50 rounded-lg transition disabled:opacity-50"
                      title="Excluir locação"
                    >
                      <svg 
                        v-if="deletingStayId !== stay.id"
                        class="w-4 h-4" 
                        fill="none" 
                        stroke="currentColor" 
                        viewBox="0 0 24 24"
                      >
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                      </svg>
                      <svg 
                        v-else
                        class="w-4 h-4 animate-spin" 
                        fill="none" 
                        viewBox="0 0 24 24"
                      >
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                      </svg>
                    </button>
                    <button
                      @click="goToStay(stay.id)"
                      class="p-2 text-indigo-600 hover:bg-indigo-50 rounded-lg transition"
                      title="Ver detalhes"
                    >
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
                      </svg>
                    </button>
                  </div>
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

<ConfirmationModal
  :isOpen="!!relatedStayToDelete"
  title="Excluir locação"
  :message="`Tem certeza que deseja excluir a locação de ${relatedStayToDelete?.guest_name || ''}?`"
  :details="relatedStayToDelete ? `Check-in: ${formatDate(relatedStayToDelete.check_in_date)}<br/>Check-out: ${formatDate(relatedStayToDelete.check_out_date)}` : ''"
  confirmLabel="Excluir"
  cancelLabel="Cancelar"
  confirmButtonColor="red"
  :loading="deletingStayId === (relatedStayToDelete && relatedStayToDelete.id)"
  @confirm="confirmDeleteRelatedStay"
  @cancel="cancelDeleteRelatedStay"
/>

<script>
import axios from 'axios'
import { navigateTo } from '../router.js'
import ConfirmationModal from './ConfirmationModal.vue'

export default {
  components: {
    ConfirmationModal
  },
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
    },
    customUpdateEndpoint: {
      type: Function,
      required: false,
      default: null
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
      relatedStays: [],
      deletingStayId: null,
      relatedStayToDelete: null
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
        const userToken = localStorage.getItem('userToken')
        const tenantToken = localStorage.getItem('tenantToken')
        const response = await axios.get(this.apiEndpoint, {
          headers: { Authorization: `Bearer ${userToken}`, 'Tenant-Authorization': `Bearer ${tenantToken}` }
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
        const userToken = localStorage.getItem('userToken')
        const tenantToken = localStorage.getItem('tenantToken')
        const headers = { Authorization: `Bearer ${userToken}`, 'Tenant-Authorization': `Bearer ${tenantToken}` }
        const resourceName = this.getResourceName()
        const baseEndpoint = this.apiEndpoint.split('?')[0]

        // Enviar apenas os campos definidos em formFields
        const cleanedForm = {}
        for (const key in this.formFields) {
          const value = this.form[key]
          if (value === undefined) continue

          const normalizedValue = await this.normalizeValueForPayload(key, value)
          if (normalizedValue !== undefined) {
            cleanedForm[key] = normalizedValue
          }
        }

        const useFormData = this.formNeedsMultipart(cleanedForm)
        const payload = useFormData ? this.buildFormData(resourceName, cleanedForm) : { [resourceName]: cleanedForm }
        const requestConfig = useFormData ? { headers } : { headers }

        if (this.editingItem) {
          const updateEndpoint = this.customUpdateEndpoint 
            ? this.customUpdateEndpoint(this.editingItem.id)
            : `${baseEndpoint}/${this.editingItem.id}`
          
          await axios.patch(updateEndpoint, payload, requestConfig)
        } else {
          await axios.post(baseEndpoint, payload, requestConfig)
        }

        this.closeModal()
        this.loadItems()
      } catch (err) {
        this.formErrors.general = err.response?.data?.errors?.join(', ') || 'Erro ao salvar'
      } finally {
        this.saving = false
      }
    },

    normalizeValueForPayload(key, value) {
      if (key === 'attachments' && Array.isArray(value)) {
        const fileOnly = value.filter(item => this.isFileLike(item))
        return fileOnly.length > 0 ? fileOnly : undefined
      }

      // Converter Data URL para Blob para foto de perfil
      if (key === 'profile_image' && typeof value === 'string' && value.startsWith('data:')) {
        return this.dataUrlToBlob(value)
      }

      // Se profile_image é uma URL HTTP (imagem existente), não enviar (não mudou)
      if (key === 'profile_image' && typeof value === 'string' && (value.startsWith('http://') || value.startsWith('https://') || value.startsWith('/'))) {
        return undefined
      }

      // Se profile_image é string vazia, não enviar
      if (key === 'profile_image' && value === '') {
        return undefined
      }

      return value
    },

    async dataUrlToBlob(dataUrl) {
      const response = await fetch(dataUrl)
      return response.blob()
    },

    formNeedsMultipart(cleanedForm) {
      return Object.values(cleanedForm).some(value => this.valueHasFile(value))
    },

    valueHasFile(value) {
      if (this.isFileLike(value)) return true
      if (Array.isArray(value)) {
        return value.some(item => this.isFileLike(item))
      }
      return false
    },

    isFileLike(value) {
      return (typeof File !== 'undefined' && value instanceof File) ||
        (typeof Blob !== 'undefined' && value instanceof Blob)
    },

    buildFormData(resourceName, cleanedForm) {
      const formData = new FormData()

      for (const key in cleanedForm) {
        const value = cleanedForm[key]

        if (Array.isArray(value)) {
          value.forEach(item => {
            if (item === undefined || item === null) return
            formData.append(`${resourceName}[${key}][]`, item)
          })
        } else if (value !== undefined) {
          formData.append(`${resourceName}[${key}]`, value === null ? '' : value)
        }
      }

      return formData
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
      this.error = null

      try {
        const userToken = localStorage.getItem('userToken')
        const tenantToken = localStorage.getItem('tenantToken')
        const baseEndpoint = this.apiEndpoint.split('?')[0]
        await axios.delete(`${baseEndpoint}/${this.deleteConfirmItem.id}`, {
          headers: { Authorization: `Bearer ${userToken}`, 'Tenant-Authorization': `Bearer ${tenantToken}` }
        })

        this.closeDeleteModal()
        this.closeModal()
        this.loadItems()
      } catch (err) {
        if (err.response?.status === 409) {
          this.deleteError = err.response.data.error
          this.deleteErrorMessage = err.response.data.message
          this.relatedStays = err.response.data.related_stays || []
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

    openDeleteRelatedStayConfirm(stay) {
      this.relatedStayToDelete = stay
    },

    async confirmDeleteRelatedStay() {
      if (!this.relatedStayToDelete) return
      await this.deleteRelatedStay(this.relatedStayToDelete.id)
      this.relatedStayToDelete = null
    },

    cancelDeleteRelatedStay() {
      this.relatedStayToDelete = null
    },

    async deleteRelatedStay(stayId) {
      if (!confirm('Tem certeza que deseja excluir esta locação?')) {
        return
      }

      this.deletingStayId = stayId

      try {
        const userToken = localStorage.getItem('userToken')
        const tenantToken = localStorage.getItem('tenantToken')
        await axios.delete(`/api/v1/stays/${stayId}`, {
          headers: { Authorization: `Bearer ${userToken}`, 'Tenant-Authorization': `Bearer ${tenantToken}` }
        })

        // Remove a locação da lista
        this.relatedStays = this.relatedStays.filter(stay => stay.id !== stayId)

        // Se não há mais locações relacionadas, tenta excluir o item novamente
        if (this.relatedStays.length === 0) {
          this.deleteError = null
          this.deleteErrorMessage = null
          await this.deleteItem()
        }
      } catch (err) {
        this.error = err.response?.data?.error || 'Erro ao excluir locação'
        setTimeout(() => { this.error = null }, 3000)
      } finally {
        this.deletingStayId = null
      }
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
