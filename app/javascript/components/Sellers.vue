<template>
  <CrudBase
    title="Corretores"
    singular-title="Corretor"
    api-endpoint="/api/v1/people?type=Seller"
    :columns="columns"
    :form-fields="formFields"
  >
    <template #form="{ form, errors }">
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
          <div class="flex items-center justify-between mb-1">
            <label class="block text-sm font-medium text-gray-700">Telefone *</label>
            <a
              v-if="phoneWhatsAppLink(form.phone)"
              :href="phoneWhatsAppLink(form.phone)"
              target="_blank"
              rel="noopener"
              class="text-gray-400 hover:text-emerald-600 transition"
              title="Abrir no WhatsApp"
            >
              <svg class="w-5 h-5" viewBox="0 0 32 32" fill="currentColor" aria-hidden="true">
                <path d="M19.11 17.36c-.28-.14-1.64-.81-1.9-.9-.26-.1-.45-.14-.64.14-.19.28-.73.9-.9 1.08-.17.19-.33.21-.61.07-.28-.14-1.16-.43-2.21-1.37-.82-.73-1.37-1.63-1.53-1.91-.16-.28-.02-.43.12-.57.12-.12.28-.33.42-.5.14-.17.19-.28.28-.47.09-.19.05-.36-.02-.5-.07-.14-.64-1.53-.88-2.1-.23-.56-.47-.48-.64-.49-.17-.01-.36-.01-.55-.01-.19 0-.5.07-.76.36-.26.28-1 1-1 2.45 0 1.44 1.03 2.84 1.17 3.04.14.19 2.02 3.08 4.89 4.31.68.29 1.21.46 1.62.58.68.22 1.31.19 1.8.12.55-.08 1.64-.67 1.87-1.31.23-.64.23-1.19.16-1.31-.07-.12-.26-.19-.54-.33z"/>
                <path d="M26.73 5.27C24.24 2.79 21.21 1.5 18 1.5 9.99 1.5 3.5 7.99 3.5 16c0 2.56.67 5.06 1.94 7.27L3 31l7.91-2.38C13.06 29.89 15.49 30.5 18 30.5 26.01 30.5 32.5 24.01 32.5 16c0-3.21-1.29-6.24-3.77-8.73zM18 28.5c-2.29 0-4.52-.62-6.47-1.8l-.46-.27-4.7 1.41 1.45-4.57-.3-.47C6.3 20.3 5.5 18.18 5.5 16 5.5 9.1 11.1 3.5 18 3.5S30.5 9.1 30.5 16 24.9 28.5 18 28.5z"/>
              </svg>
            </a>
          </div>
          <input
            v-model="form.phone"
            @input="applyPhoneMask"
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
            @input="applyCpfMask"
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
            @input="applyRgMask"
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
            ref="zipInput"
            v-model="form.zip"
            @input="fetchAddressByCep"
            type="text"
            placeholder="00000-000"
            maxlength="9"
            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Endereço</label>
          <input
            ref="addressInput"
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
            ref="neighborhoodInput"
            v-model="form.neighborhood"
            type="text"
            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Cidade</label>
          <input
            ref="cityInput"
            v-model="form.city"
            type="text"
            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Estado</label>
          <SelectWithFilter 
            ref="stateInput"
            v-model="form.state"
            :options="stateOptions"
          />
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
          <label class="flex items-center space-x-3 p-4 border-2 border-gray-200 rounded-lg hover:border-indigo-300 transition cursor-pointer group">
            <input
              v-model="form.blocked"
              type="checkbox"
              class="w-5 h-5 text-red-600 border-gray-300 rounded focus:ring-2 focus:ring-red-500 cursor-pointer"
            />
            <div class="flex-1">
              <span class="text-sm font-semibold text-gray-900">Corretor bloqueado</span>
              <p class="text-xs text-gray-500 mt-0.5">Esta pessoa não poderá ser selecionada em novas operações</p>
            </div>
            <svg class="w-5 h-5 text-red-500 opacity-0 group-hover:opacity-100 transition" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
            </svg>
          </label>
        </div>

        <input type="hidden" v-model="form.type" value="Seller" />
      </div>
    </template>
  </CrudBase>
</template>

<script>
import CrudBase from './CrudBase.vue'
import SelectWithFilter from './SelectWithFilter.vue'
import { BRAZILIAN_STATES } from '../constants/brazilianStates.js'
import { useBrazilianMasks } from '../composables/useBrazilianMasks.js'
import { useViaCep } from '../composables/useViaCep.js'

const { getWhatsAppLink, handlePhoneInput, handleCpfInput, handleRgInput } = useBrazilianMasks()
const { handleCepLookup } = useViaCep()

export default {
  components: {
    CrudBase,
    SelectWithFilter
  },

  data() {
    return {
      stateOptions: BRAZILIAN_STATES,
      columns: [
        { key: 'name', label: 'Nome' },
        { key: 'cpf', label: 'CPF' },
        { key: 'phone', label: 'Telefone' },
        { key: 'email', label: 'E-mail' },
        { 
          key: 'city', 
          label: 'Cidade',
          format: (value, item) => item.state ? `${value} - ${item.state}` : value
        }
      ],
      formFields: {
        name: '',
        cpf: '',
        rg: '',
        phone: '',
        email: '',
        profession: '',
        marital_status: '',
        city: '',
        state: '',
        address: '',
        number: '',
        neighborhood: '',
        zip: '',
        note: '',
        blocked: false,
        type: 'Seller'
      }
    }
  },

  methods: {
    fetchAddressByCep(event) {
      handleCepLookup(event, this.$refs, this.form)
    },

    applyPhoneMask(event) {
      handlePhoneInput(event, this.form)
    },

    applyCpfMask(event) {
      handleCpfInput(event, this.form)
    },

    applyRgMask(event) {
      handleRgInput(event, this.form)
    },

    phoneWhatsAppLink(phone) {
      return getWhatsAppLink(phone)
    }
  }
}
</script>
