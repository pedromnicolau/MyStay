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
          <label class="block text-sm font-medium text-gray-700 mb-1">Telefone *</label>
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
          <label class="flex items-center space-x-2">
            <input
              v-model="form.blocked"
              type="checkbox"
              class="w-4 h-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500"
            />
            <span class="text-sm font-medium text-gray-700">Corretor bloqueado</span>
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

const stateOptions = [
  { value: 'AC', label: 'Acre' },
  { value: 'AL', label: 'Alagoas' },
  { value: 'AP', label: 'Amapá' },
  { value: 'AM', label: 'Amazonas' },
  { value: 'BA', label: 'Bahia' },
  { value: 'CE', label: 'Ceará' },
  { value: 'DF', label: 'Distrito Federal' },
  { value: 'ES', label: 'Espírito Santo' },
  { value: 'GO', label: 'Goiás' },
  { value: 'MA', label: 'Maranhão' },
  { value: 'MT', label: 'Mato Grosso' },
  { value: 'MS', label: 'Mato Grosso do Sul' },
  { value: 'MG', label: 'Minas Gerais' },
  { value: 'PA', label: 'Pará' },
  { value: 'PB', label: 'Paraíba' },
  { value: 'PR', label: 'Paraná' },
  { value: 'PE', label: 'Pernambuco' },
  { value: 'PI', label: 'Piauí' },
  { value: 'RJ', label: 'Rio de Janeiro' },
  { value: 'RN', label: 'Rio Grande do Norte' },
  { value: 'RS', label: 'Rio Grande do Sul' },
  { value: 'RO', label: 'Rondônia' },
  { value: 'RR', label: 'Roraima' },
  { value: 'SC', label: 'Santa Catarina' },
  { value: 'SP', label: 'São Paulo' },
  { value: 'SE', label: 'Sergipe' },
  { value: 'TO', label: 'Tocantins' }
]

export default {
  components: {
    CrudBase,
    SelectWithFilter
  },

  data() {
    return {
      stateOptions,
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
    async fetchAddressByCep(event) {
      const cepInput = event.target
      let value = cepInput.value.replace(/\D/g, '')
      let formattedValue = ''
      
      if (value.length > 5) {
        formattedValue = `${value.slice(0, 5)}-${value.slice(5, 8)}`
      } else {
        formattedValue = value
      }
      
      cepInput.value = formattedValue
      
      // Se o CEP está completo, buscar dados
      if (value.length === 8) {
        try {
          const response = await fetch(`https://viacep.com.br/ws/${value}/json/`)
          const data = await response.json()
          
          if (data.logradouro) {
            // Usar os refs para preencher os campos
            if (this.$refs.addressInput) {
              this.$refs.addressInput.value = data.logradouro
              this.$refs.addressInput.dispatchEvent(new Event('input', { bubbles: true }))
            }
            if (this.$refs.neighborhoodInput) {
              this.$refs.neighborhoodInput.value = data.bairro
              this.$refs.neighborhoodInput.dispatchEvent(new Event('input', { bubbles: true }))
            }
            if (this.$refs.cityInput) {
              this.$refs.cityInput.value = data.localidade
              this.$refs.cityInput.dispatchEvent(new Event('input', { bubbles: true }))
            }
            // State é handled via v-model no SelectWithFilter
            if (this.$refs.stateInput) {
              this.$refs.stateInput.$emit('update:modelValue', data.uf)
            }
          }
        } catch (error) {
          console.error('Erro ao buscar CEP:', error)
        }
      }
    },

    applyPhoneMask(event) {
      let value = event.target.value.replace(/\D/g, '')
      let formattedValue = ''
      
      if (value.length <= 10) {
        // Formato: (00) 0000-0000
        if (value.length > 6) {
          formattedValue = `(${value.slice(0, 2)}) ${value.slice(2, 6)}-${value.slice(6, 10)}`
        } else if (value.length > 2) {
          formattedValue = `(${value.slice(0, 2)}) ${value.slice(2, 6)}`
        } else if (value.length > 0) {
          formattedValue = `(${value.slice(0, 2)}`
        }
      } else {
        // Formato: (00) 00000-0000
        formattedValue = `(${value.slice(0, 2)}) ${value.slice(2, 7)}-${value.slice(7, 11)}`
      }
      
      event.target.value = formattedValue
      this.form.phone = formattedValue
    },

    applyCpfMask(event) {
      let value = event.target.value.replace(/\D/g, '')
      let formattedValue = ''
      
      if (value.length > 9) {
        formattedValue = `${value.slice(0, 3)}.${value.slice(3, 6)}.${value.slice(6, 9)}-${value.slice(9, 11)}`
      } else if (value.length > 6) {
        formattedValue = `${value.slice(0, 3)}.${value.slice(3, 6)}.${value.slice(6, 9)}`
      } else if (value.length > 3) {
        formattedValue = `${value.slice(0, 3)}.${value.slice(3, 6)}`
      } else {
        formattedValue = value
      }
      
      event.target.value = formattedValue
      this.form.cpf = formattedValue
    },

    applyRgMask(event) {
      let value = event.target.value.replace(/\D/g, '')
      let formattedValue = ''
      
      if (value.length > 8) {
        formattedValue = `${value.slice(0, 2)}.${value.slice(2, 5)}.${value.slice(5, 8)}-${value.slice(8, 9)}`
      } else if (value.length > 5) {
        formattedValue = `${value.slice(0, 2)}.${value.slice(2, 5)}.${value.slice(5)}`
      } else if (value.length > 2) {
        formattedValue = `${value.slice(0, 2)}.${value.slice(2)}`
      } else {
        formattedValue = value
      }
      
      event.target.value = formattedValue
      this.form.rg = formattedValue
    },

    applyZipMask(event) {
      let value = event.target.value.replace(/\D/g, '')
      let formattedValue = ''
      
      if (value.length > 5) {
        formattedValue = `${value.slice(0, 5)}-${value.slice(5, 8)}`
      } else {
        formattedValue = value
      }
      
      event.target.value = formattedValue
      this.form.zip = formattedValue
    }
  }
}
</script>
