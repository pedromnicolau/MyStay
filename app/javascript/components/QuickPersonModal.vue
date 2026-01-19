<template>
  <div
    v-if="isOpen"
    class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
    @click.self="closeModal"
  >
    <div class="bg-white rounded-lg shadow-xl max-w-md w-full max-h-[90vh] flex flex-col overflow-hidden">
      <div class="px-6 py-4 border-b border-gray-200 flex justify-between items-center flex-shrink-0">
        <h2 class="text-xl font-semibold text-gray-900">{{ title }}</h2>
        <button @click="closeModal" class="text-gray-400 hover:text-gray-600">
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>

      <form @submit.prevent="save" class="px-6 py-4 overflow-y-auto flex-1 flex flex-col">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Nome *</label>
            <input
              v-model="form.name"
              type="text"
              required
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">E-mail</label>
            <input
              v-model="form.email"
              type="email"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Telefone *</label>
            <input
              v-model="form.phone"
              @input="handlePhoneMaskInput"
              type="tel"
              required
              placeholder="(00) 00000-0000"
              maxlength="15"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">CPF *</label>
            <input
              v-model="form.cpf"
              @input="handleCpfMaskInput"
              type="text"
              required
              placeholder="000.000.000-00"
              maxlength="14"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">RG</label>
            <input
              v-model="form.rg"
              @input="handleRgMaskInput"
              type="text"
              maxlength="12"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Profissão</label>
            <input
              v-model="form.profession"
              type="text"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Estado Civil</label>
            <select
              v-model="form.marital_status"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            >
              <option value="">Selecione</option>
              <option value="Solteiro(a)">Solteiro(a)</option>
              <option value="Casado(a)">Casado(a)</option>
              <option value="Divorciado(a)">Divorciado(a)</option>
              <option value="Viúvo(a)">Viúvo(a)</option>
            </select>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">CEP</label>
            <input
              v-model="form.zip"
              @input="handleZipInput"
              type="text"
              placeholder="00000-000"
              maxlength="9"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Endereço</label>
            <input
              v-model="form.address"
              type="text"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Número</label>
            <input
              v-model="form.number"
              type="text"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Bairro</label>
            <input
              v-model="form.neighborhood"
              type="text"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Cidade</label>
            <input
              v-model="form.city"
              type="text"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Estado</label>
            <select
              v-model="form.state"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            >
              <option value="">Selecione</option>
              <option v-for="state in stateOptions" :key="state.value" :value="state.value">
                {{ state.label }}
              </option>
            </select>
          </div>

          <div class="md:col-span-2">
            <label class="block text-sm font-medium text-gray-700 mb-1">Observações</label>
            <textarea
              v-model="form.note"
              rows="3"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            ></textarea>
          </div>

          <div class="md:col-span-2">
            <label class="flex items-center space-x-2">
              <input
                v-model="form.blocked"
                type="checkbox"
                class="w-4 h-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500"
              />
              <span class="text-sm font-medium text-gray-700">{{ blockLabel }}</span>
            </label>
          </div>
        </div>
      </form>

      <div class="px-6 py-4 border-t border-gray-200 flex-shrink-0 bg-white flex justify-end space-x-3 relative">
        <div v-if="errors.general" class="absolute left-6 -top-12 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg w-[calc(100%-3rem)]">
          {{ errors.general }}
        </div>
        <button
          type="button"
          @click="closeModal"
          class="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition"
        >
          Cancelar
        </button>
        <button
          type="button"
          @click="save"
          :disabled="saving"
          class="px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition disabled:opacity-50"
        >
          {{ saving ? 'Salvando...' : 'Salvar' }}
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { useInputMasks } from '../composables/useInputMasks.js'
import { useApi } from '../composables/useApi.js'
import { BRAZILIAN_STATES } from '../constants/brazilianStates.js'

export default {
  props: {
    isOpen: {
      type: Boolean,
      required: true
    },
    personType: {
      type: String,
      required: true,
      validator: (value) => ['Customer', 'Seller', 'Cleaner'].includes(value)
    },
    onSave: {
      type: Function,
      required: true
    },
    onClose: {
      type: Function,
      required: true
    }
  },

  data() {
    const { applyPhoneMask, applyCpfMask, applyRgMask, applyZipMask, fetchAddressByCep } = useInputMasks()

    return {
      applyPhoneMask,
      applyCpfMask,
      applyRgMask,
      applyZipMask,
      fetchAddressByCep,
      saving: false,
      errors: {},
      form: {
        name: '',
        email: '',
        phone: '',
        cpf: '',
        rg: '',
        profession: '',
        marital_status: '',
        zip: '',
        address: '',
        number: '',
        neighborhood: '',
        city: '',
        state: '',
        note: '',
        blocked: false,
        type: ''
      },
      stateOptions: BRAZILIAN_STATES
    }
  },

  computed: {
    title() {
      const titles = {
        Customer: 'Novo Hóspede',
        Seller: 'Novo Corretor',
        Cleaner: 'Nova Faxineira'
      }
      return titles[this.personType] || 'Novo Registro'
    },

    blockLabel() {
      const labels = {
        Customer: 'Cliente bloqueado',
        Seller: 'Corretor bloqueado',
        Cleaner: 'Faxineira bloqueada'
      }
      return labels[this.personType] || 'Bloqueado'
    }
  },

  watch: {
    isOpen(newVal) {
      if (newVal) {
        this.form.type = this.personType
      }
    }
  },

  methods: {
    handlePhoneMaskInput(event) {
      event.target.value = this.applyPhoneMask(event.target.value)
    },

    handleCpfMaskInput(event) {
      event.target.value = this.applyCpfMask(event.target.value)
    },

    handleRgMaskInput(event) {
      event.target.value = this.applyRgMask(event.target.value)
    },

    async handleZipInput(event) {
      event.target.value = this.applyZipMask(event.target.value)
      const cleanZip = event.target.value.replace(/\D/g, '')
      
      if (cleanZip.length === 8) {
        await this.fetchAddressByCep(cleanZip, this.form)
      }
    },

    async save() {
      this.saving = true
      this.errors = {}

      try {
        const { post } = useApi()
        const { data, error } = await post('/api/v1/people', { person: this.form })

        if (error) {
          this.errors.general = error.response?.data?.errors?.join(', ') || 'Erro ao criar registro'
          return
        }

        this.onSave(data)
        this.closeModal()
      } catch (err) {
        this.errors.general = err.response?.data?.errors?.join(', ') || 'Erro ao criar registro'
      } finally {
        this.saving = false
      }
    },

    closeModal() {
      this.form = {
        name: '',
        email: '',
        phone: '',
        cpf: '',
        rg: '',
        profession: '',
        marital_status: '',
        zip: '',
        address: '',
        number: '',
        neighborhood: '',
        city: '',
        state: '',
        note: '',
        blocked: false,
        type: ''
      }
      this.errors = {}
      this.onClose()
    }
  }
}
</script>
