<template>
  <CrudBase
    title="Pessoas"
    singular-title="Pessoa"
    api-endpoint="/api/v1/people"
    :columns="columns"
    :form-fields="formFields"
  >
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
      columns: [
        {
          key: 'profile_image',
          label: 'Foto'
        },
        { key: 'name', label: 'Nome' },
        { key: 'cpf', label: 'CPF' },
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
        profile_image: '',
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
        customer: false,
        provider: false,
        agent: false
      }
    }
  }
}
</script>
