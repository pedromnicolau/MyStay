<template>
  <CrudBase
    title="Pessoas"
    singular-title="Pessoa"
    api-endpoint="/api/v1/people"
    :columns="columns"
    :form-fields="formFields"
  >
    <template #filters="{ loadItems }">
      <div class="bg-white rounded-lg shadow-sm p-6 mb-6">
        <h2 class="text-lg font-semibold text-gray-900 mb-4">Filtros</h2>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Nome</label>
            <input
              v-model="filters.name"
              type="text"
              placeholder="Buscar por nome"
              @keyup.enter="applyFilters(loadItems)"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Cidade</label>
            <input
              v-model="filters.city"
              type="text"
              placeholder="Buscar por cidade"
              @keyup.enter="applyFilters(loadItems)"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>
          <div class="flex items-end">
            <button
              @click="applyFilters(loadItems)"
              class="w-full bg-indigo-600 text-white px-6 py-2 rounded-lg hover:bg-indigo-700 transition flex items-center justify-center space-x-2"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
              <span>Buscar</span>
            </button>
          </div>
        </div>
      </div>
    </template>

    <template #form="{ form, errors }">
      <PersonForm :form="form" block-label="Pessoa bloqueada" />
    </template>
  </CrudBase>
</template>

<script>
import CrudBase from './CrudBase.vue'
import PersonForm from './PersonForm.vue'
import { BRAZILIAN_STATES } from '../constants/brazilianStates.js'

export default {
  components: {
    CrudBase,
    PersonForm
  },

  data() {
    return {
      stateOptions: BRAZILIAN_STATES,
      filters: {
        name: '',
        city: ''
      },
      columns: [
        { key: 'name', label: 'Nome' },
        { key: 'document', label: 'CPF/CNPJ' },
        { key: 'phone', label: 'Telefone' },
        { key: 'email', label: 'E-mail' },
        {
          key: 'roles',
          label: 'Perfis',
          format: (value, item) => {
            const roles = []
            if (item.customer) roles.push('Cliente')
            if (item.agent) roles.push('Corretor')
            if (item.provider) roles.push('Prestador')
            return roles.join(', ')
          }
        },
        {
          key: 'city',
          label: 'Cidade',
          format: (value, item) => item.state ? `${value} - ${item.state}` : value
        }
      ],
      formFields: {
        name: '',
        document: '',
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
        customer: false,
        provider: false,
        agent: false
      }
    }
  },

  methods: {
    applyFilters(loadItems) {
      const params = {}
      
      if (this.filters.name) {
        params.name = this.filters.name
      }
      if (this.filters.city) {
        params.city = this.filters.city
      }
      
      loadItems(params)
    }
  }
}
</script>
