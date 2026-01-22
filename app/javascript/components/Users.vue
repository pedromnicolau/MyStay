<template>
  <CrudBase
    title="Usuários"
    singular-title="Usuário"
    api-endpoint="/api/v1/users"
    :columns="columns"
    :form-fields="formFields"
    :custom-update-endpoint="getUpdateEndpoint"
  >
    <template #form="{ form, errors }">
      <div class="space-y-4">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label for="first_name" class="block text-sm font-medium text-gray-700 mb-1">
              Nome <span class="text-red-500">*</span>
            </label>
            <input
              v-model="form.first_name"
              id="first_name"
              type="text"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
              :class="{ 'border-red-500': errors.first_name }"
              required
            />
            <span v-if="errors.first_name" class="text-red-500 text-sm">{{ errors.first_name }}</span>
          </div>

          <div>
            <label for="last_name" class="block text-sm font-medium text-gray-700 mb-1">
              Sobrenome <span class="text-red-500">*</span>
            </label>
            <input
              v-model="form.last_name"
              id="last_name"
              type="text"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
              :class="{ 'border-red-500': errors.last_name }"
              required
            />
            <span v-if="errors.last_name" class="text-red-500 text-sm">{{ errors.last_name }}</span>
          </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label for="email" class="block text-sm font-medium text-gray-700 mb-1">
              E-mail <span class="text-red-500">*</span>
            </label>
            <input
              v-model="form.email"
              id="email"
              type="email"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
              :class="{ 'border-red-500': errors.email }"
              required
            />
            <span v-if="errors.email" class="text-red-500 text-sm">{{ errors.email }}</span>
          </div>

          <div>
            <label for="phone" class="block text-sm font-medium text-gray-700 mb-1">
              Telefone
            </label>
            <input
              v-model="form.phone"
              id="phone"
              type="text"
              @input="masks.handlePhoneMaskInput"
              placeholder="(00) 00000-0000"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>
        </div>

        <div class="border-t pt-4">
          <h3 class="text-lg font-medium text-gray-900 mb-3">Senha</h3>
          <p class="text-sm text-gray-600 mb-3">
            {{ form.id ? 'Deixe em branco para manter a senha atual' : 'Defina uma senha para o novo usuário' }}
          </p>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label for="password" class="block text-sm font-medium text-gray-700 mb-1">
                Senha {{ !form.id ? '*' : '' }}
              </label>
              <input
                v-model="form.password"
                id="password"
                type="password"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
                :class="{ 'border-red-500': errors.password }"
                :required="!form.id"
              />
              <span v-if="errors.password" class="text-red-500 text-sm">{{ errors.password }}</span>
            </div>

            <div>
              <label for="password_confirmation" class="block text-sm font-medium text-gray-700 mb-1">
                Confirmar Senha {{ !form.id ? '*' : '' }}
              </label>
              <input
                v-model="form.password_confirmation"
                id="password_confirmation"
                type="password"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
                :class="{ 'border-red-500': errors.password_confirmation }"
                :required="!form.id"
              />
              <span v-if="errors.password_confirmation" class="text-red-500 text-sm">{{ errors.password_confirmation }}</span>
            </div>
          </div>
        </div>

        
      </div>
    </template>
  </CrudBase>
</template>

<script>
import CrudBase from './CrudBase.vue'
import { useBrazilianMasks } from '../composables/useBrazilianMasks.js'

export default {
  components: {
    CrudBase
  },

  data() {
    return {
      masks: useBrazilianMasks(),
      columns: [
        { 
          key: 'name', 
          label: 'Nome',
          format: (value, item) => `${item.first_name || ''} ${item.last_name || ''}`.trim() || '-'
        },
        { key: 'email', label: 'E-mail' },
        { key: 'phone', label: 'Telefone' },
        
      ],
      formFields: {
        first_name: '',
        last_name: '',
        email: '',
        phone: '',
        password: '',
        password_confirmation: ''
      }
    }
  },

  methods: {
    getUpdateEndpoint(id) {
      return `/api/v1/users/${id}/update_user`
    }
  }
}
</script>
