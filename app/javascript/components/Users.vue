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
        <!-- Avatar Section -->
        <div class="flex justify-center mb-6">
          <div class="relative">
            <div class="w-24 h-24 rounded-full overflow-hidden bg-gradient-to-br from-indigo-100 to-indigo-200 flex items-center justify-center border-4 border-white shadow-lg">
              <img
                v-if="form.profile_image"
                :src="form.profile_image"
                :alt="`${form.first_name || 'Usuário'} ${form.last_name || ''}`"
                class="w-full h-full object-cover"
              />
              <div v-else class="text-3xl font-semibold text-indigo-600">
                {{ getUserInitials(form) }}
              </div>
            </div>
            <div class="absolute bottom-0 right-0 w-8 h-8 bg-white rounded-full shadow-md flex items-center justify-center border-2 border-gray-100">
              <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
              </svg>
            </div>
          </div>
        </div>

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
    },

    getUserInitials(form) {
      const first = (form.first_name || '').trim()
      const last = (form.last_name || '').trim()
      
      if (first && last) {
        return `${first[0]}${last[0]}`.toUpperCase()
      } else if (first) {
        return first.substring(0, 2).toUpperCase()
      } else if (form.email) {
        return form.email.substring(0, 2).toUpperCase()
      }
      
      return 'U'
    }
  }
}
</script>
