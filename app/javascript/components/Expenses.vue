<template>
  <div class="min-h-screen bg-gray-50">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div class="mb-6 flex justify-between items-center">
        <h1 class="text-3xl font-bold text-gray-900">Despesas</h1>
        <button
          @click="openCreateModal"
          class="px-6 py-2.5 rounded-lg transition flex items-center space-x-2 shadow-sm bg-red-600 text-white hover:bg-red-700"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
          </svg>
          <span>Nova Despesa</span>
        </button>
      </div>

      <div v-if="loading" class="flex justify-center items-center h-64">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-red-600"></div>
      </div>

      <div v-else class="bg-white rounded-lg shadow-sm overflow-hidden">
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Data</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Prestador</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Imóvel</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Descrição</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Valor</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Ações</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr v-for="expense in sortedExpenses" :key="expense.id" class="hover:bg-gray-50">
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {{ formatDate(expense.check_in_date) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {{ expense.customer?.name || '-' }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                  {{ expense.property?.name || '-' }}
                </td>
                <td class="px-6 py-4 text-sm text-gray-600">
                  {{ expense.description || '-' }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-red-600">
                  R$ {{ formatCurrency(expense.total_price) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  <div class="flex space-x-2">
                    <button
                      @click="editExpense(expense)"
                      class="text-indigo-600 hover:text-indigo-900"
                      title="Editar"
                    >
                      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                      </svg>
                    </button>
                    <button
                      @click="confirmDelete(expense)"
                      class="text-red-600 hover:text-red-900"
                      title="Excluir"
                    >
                      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                      </svg>
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="expenses.length === 0">
                <td colspan="6" class="px-6 py-12 text-center text-gray-500">
                  Nenhuma despesa cadastrada
                </td>
              </tr>
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
      <div class="bg-white rounded-lg shadow-xl max-w-2xl w-full max-h-[90vh] flex flex-col overflow-hidden">
        <div class="px-6 py-4 border-b border-gray-200 flex justify-between items-center flex-shrink-0 bg-white">
          <h2 class="text-xl font-semibold text-gray-900">
            {{ editingExpense ? 'Editar Despesa' : 'Nova Despesa' }}
          </h2>
          <button @click="closeModal" class="text-gray-400 hover:text-gray-600">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <form @submit.prevent="saveExpense" class="px-6 py-4 overflow-y-auto flex-1 flex flex-col">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Data *</label>
              <input
                v-model="form.check_in_date"
                type="date"
                required
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Valor (R$) *</label>
              <input
                v-model="form.total_price"
                type="text"
                @input="handleCurrencyInput($event, 'total_price')"
                required
                placeholder="0,00"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500"
              />
            </div>

            <div>
              <PersonSelect
                v-model="form.customer_id"
                :options="providerOptions"
                :selected-person="selectedProvider"
                label="Prestador *"
                @update:modelValue="handleProviderChange"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Imóvel</label>
              <select
                v-model="form.property_id"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500"
              >
                <option value="">Selecione um imóvel</option>
                <option v-for="property in properties" :key="property.id" :value="property.id">
                  {{ property.name }}
                </option>
              </select>
            </div>

            <div class="md:col-span-2">
              <label class="block text-sm font-medium text-gray-700 mb-1">Descrição/Comentário</label>
              <textarea
                v-model="form.description"
                rows="3"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500"
                placeholder="Detalhes sobre a despesa..."
              ></textarea>
            </div>

            <div class="md:col-span-2">
              <label class="block text-sm font-medium text-gray-700 mb-2">Anexos</label>
              <AttachmentManager
                v-model="form.attachments"
                v-model:remove-attachment-ids="form.remove_attachment_ids"
                :accepted-types="'*'"
                :enable-reorder="true"
                :enable-lightbox="true"
              />
            </div>
          </div>
        </form>

        <div class="px-6 py-4 border-t border-gray-200 flex-shrink-0 bg-white flex justify-between items-center relative">
          <div v-if="formErrors.general" class="absolute left-6 -top-12 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg w-[calc(100%-3rem)] flex items-start justify-between">
            <span class="flex-1">{{ formErrors.general }}</span>
            <button 
              @click="formErrors.general = ''"
              class="ml-3 text-red-700 hover:text-red-900 flex-shrink-0"
              type="button"
            >
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
          <button
            v-if="editingExpense"
            type="button"
            @click="deleteConfirmExpense = editingExpense"
            class="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition"
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
              @click="saveExpense"
              :disabled="saving"
              class="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition disabled:opacity-50"
            >
              {{ saving ? 'Salvando...' : 'Salvar' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <ConfirmationModal
      :isOpen="!!deleteConfirmExpense"
      title="Confirmar Exclusão"
      message="Tem certeza que deseja excluir esta despesa? Esta ação não pode ser desfeita."
      :loading="deleting"
      @confirm="deleteExpense"
      @cancel="deleteConfirmExpense = null"
    />

    <QuickPersonModal
      :isOpen="quickPersonModalOpen.isOpen"
      :personType="quickPersonModalOpen.type"
      @save="handleQuickPersonSave"
      @close="closeQuickPersonModal"
    />
  </div>
</template>

<script>
import ConfirmationModal from './ConfirmationModal.vue'
import PersonSelect from './PersonSelect.vue'
import AttachmentManager from './AttachmentManager.vue'
import QuickPersonModal from './QuickPersonModal.vue'
import { useBrazilianMasks } from '../composables/useBrazilianMasks.js'
import { useApi } from '../composables/useApi.js'

export default {
  components: {
    ConfirmationModal,
    PersonSelect,
    AttachmentManager,
    QuickPersonModal
  },

  data() {
    const { applyCurrencyMask, parseCurrencyToNumber } = useBrazilianMasks()

    return {
      applyCurrencyMask,
      parseCurrencyToNumber,
      expenses: [],
      providers: [],
      properties: [],
      loading: false,
      isModalOpen: false,
      editingExpense: null,
      saving: false,
      deleteConfirmExpense: null,
      deleting: false,
      formErrors: {},
      form: this.getEmptyForm(),
      quickPersonModalOpen: {
        isOpen: false,
        type: null
      }
    }
  },

  computed: {
    sortedExpenses() {
      return [...this.expenses].sort((a, b) => {
        return new Date(b.check_in_date) - new Date(a.check_in_date)
      })
    },

    providerOptions() {
      return [
        { value: 'new', label: '+ Novo Prestador' },
        ...this.providers.map(p => ({ value: String(p.id), label: p.name }))
      ]
    },

    selectedProvider() {
      const id = String(this.form.customer_id || '')
      if (!id) return null
      return this.providers.find(p => String(p.id) === id) || null
    }
  },

  mounted() {
    this.loadData()
  },

  methods: {
    getEmptyForm() {
      return {
        customer_id: '',
        property_id: '',
        check_in_date: '',
        total_price: '0,00',
        description: '',
        attachments: [],
        remove_attachment_ids: [],
        attachments_order: []
      }
    },

    async loadData() {
      this.loading = true
      try {
        const { getPeople, getProperties } = useApi()
        await Promise.all([
          this.loadExpenses(),
          this.loadProviders(getPeople),
          this.loadProperties(getProperties)
        ])
      } finally {
        this.loading = false
      }
    },

    async loadExpenses() {
      try {
        const { get } = useApi()
        const { data, error } = await get('/api/v1/expenses')
        if (!error) this.expenses = data
      } catch (err) {
        console.error('Error loading expenses:', err)
      }
    },

    async loadProviders(apiMethod) {
      try {
        const { data, error } = await apiMethod('provider')
        if (!error) this.providers = data.filter(p => !p.blocked)
      } catch (err) {
        console.error('Error loading providers:', err)
      }
    },

    async loadProperties(apiMethod) {
      try {
        const { data, error } = await apiMethod()
        if (!error) this.properties = data
      } catch (err) {
        console.error('Error loading properties:', err)
      }
    },

    formatDate(dateString) {
      const date = new Date(dateString + 'T00:00:00')
      return date.toLocaleDateString('pt-BR')
    },

    formatCurrency(value) {
      const numValue = typeof value === 'string' ? parseFloat(value.replace(',', '.')) : parseFloat(value || 0)
      return numValue.toLocaleString('pt-BR', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
      })
    },

    handleCurrencyInput(event, fieldName) {
      const cursorPosition = event.target.selectionStart
      const oldValue = event.target.value
      const oldLength = oldValue.length
      
      const newValue = this.applyCurrencyMask(event.target.value)
      
      this.form[fieldName] = newValue
      
      this.$nextTick(() => {
        const newLength = newValue.length
        const diff = newLength - oldLength
        const newCursorPosition = Math.max(0, cursorPosition + diff)
        event.target.setSelectionRange(newCursorPosition, newCursorPosition)
      })
    },

    openCreateModal() {
      this.editingExpense = null
      this.form = this.getEmptyForm()
      this.formErrors = {}
      this.isModalOpen = true
    },

    editExpense(expense) {
      this.editingExpense = expense
      
      const formatMoneyValue = (value) => {
        const numValue = typeof value === 'string' ? parseFloat(value.replace(/[^0-9.-]/g, '')) : parseFloat(value || 0)
        return this.formatCurrency(numValue)
      }
      
      this.form = {
        ...this.getEmptyForm(),
        ...expense,
        customer_id: expense.customer_id ? String(expense.customer_id) : '',
        property_id: expense.property_id || '',
        total_price: formatMoneyValue(expense.total_price)
      }
      this.formErrors = {}
      this.isModalOpen = true
    },

    closeModal() {
      if (this.form.attachments) {
        this.form.attachments.forEach(item => {
          const isFile = (typeof File !== 'undefined' && item instanceof File) ||
            (typeof Blob !== 'undefined' && item instanceof Blob)
          if (isFile && item.previewUrl) {
            URL.revokeObjectURL(item.previewUrl)
          }
        })
      }
      
      this.isModalOpen = false
      this.editingExpense = null
      this.form = this.getEmptyForm()
      this.formErrors = {}
    },

    buildExpenseFormData() {
      const isFile = (item) => (typeof File !== 'undefined' && item instanceof File) ||
        (typeof Blob !== 'undefined' && item instanceof Blob)
      const newFiles = (this.form.attachments || []).filter(item => isFile(item))
      const hasNewFiles = newFiles.length > 0
      const hasRemovedAttachments = this.form.remove_attachment_ids && this.form.remove_attachment_ids.length > 0
      const hasAttachmentsOrder = this.form.attachments_order && this.form.attachments_order.length > 0

      const expenseData = {
        customer_id: this.form.customer_id,
        property_id: this.form.property_id || null,
        check_in_date: this.form.check_in_date,
        check_out_date: this.form.check_in_date,
        total_price: this.parseCurrencyToNumber(this.form.total_price || '0'),
        description: this.form.description || ''
      }

      if (!hasNewFiles && !hasRemovedAttachments && !hasAttachmentsOrder) {
        return { useFormData: false, payload: expenseData }
      }

      if (!hasNewFiles) {
        if (hasRemovedAttachments) {
          expenseData.remove_attachment_ids = this.form.remove_attachment_ids
        }
        if (hasAttachmentsOrder) {
          expenseData.attachments_order = this.form.attachments_order
        }
        return { useFormData: false, payload: expenseData }
      }

      const formData = new FormData()
      
      Object.keys(expenseData).forEach(key => {
        const value = expenseData[key]
        if (value !== null && value !== undefined && value !== '') {
          formData.append(`expense[${key}]`, value)
        }
      })

      newFiles.forEach((file) => {
        formData.append(`expense[attachments][]`, file, file.name)
      })

      if (hasRemovedAttachments) {
        this.form.remove_attachment_ids.forEach(id => {
          formData.append(`expense[remove_attachment_ids][]`, id)
        })
      }

      if (this.form.attachments_order && this.form.attachments_order.length > 0) {
        this.form.attachments_order.forEach(id => {
          formData.append(`expense[attachments_order][]`, id)
        })
      }

      return { useFormData: true, payload: formData }
    },

    async saveExpense() {
      this.saving = true
      this.formErrors = {}

      try {
        const { post, put, postFormData, putFormData } = useApi()
        const { useFormData, payload } = this.buildExpenseFormData()

        let result
        if (this.editingExpense) {
          if (useFormData) {
            result = await putFormData(`/api/v1/expenses/${this.editingExpense.id}`, payload)
          } else {
            result = await put(`/api/v1/expenses/${this.editingExpense.id}`, { expense: payload })
          }
        } else {
          if (useFormData) {
            result = await postFormData('/api/v1/expenses', payload)
          } else {
            result = await post('/api/v1/expenses', { expense: payload })
          }
        }

        if (result.error) {
          this.formErrors.general = result.error.response?.data?.errors?.join(', ') || 'Erro ao salvar despesa'
          return
        }

        this.closeModal()
        this.loadExpenses()
      } catch (err) {
        this.formErrors.general = err.response?.data?.errors?.join(', ') || 'Erro ao salvar despesa'
      } finally {
        this.saving = false
      }
    },

    confirmDelete(expense) {
      this.deleteConfirmExpense = expense
    },

    async deleteExpense() {
      this.deleting = true

      try {
        const { delete: deleteApi } = useApi()
        const { error } = await deleteApi(`/api/v1/expenses/${this.deleteConfirmExpense.id}`)

        if (!error) {
          this.deleteConfirmExpense = null
          this.closeModal()
          this.loadExpenses()
        }
      } catch (err) {
        console.error('Error deleting expense:', err)
        this.deleteConfirmExpense = null
      } finally {
        this.deleting = false
      }
    },

    handleProviderChange(value) {
      if (value === 'new') {
        this.quickPersonModalOpen = { isOpen: true, type: 'Provider' }
        this.form.customer_id = ''
      }
    },

    handleQuickPersonSave(person) {
      this.form.customer_id = person.id
      this.loadProviders(useApi().getPeople)
      this.closeQuickPersonModal()
    },

    closeQuickPersonModal() {
      this.quickPersonModalOpen = { isOpen: false, type: null }
    }
  }
}
</script>
