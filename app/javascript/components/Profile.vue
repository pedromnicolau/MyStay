<template>
  <div class="min-h-screen bg-gray-50">
    <div class="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <!-- Header -->
      <div class="mb-8">
        <button @click="goBack" class="flex items-center space-x-2 text-indigo-600 hover:text-indigo-700 mb-4 transition">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
          <span>Voltar</span>
        </button>
        <h1 class="text-3xl font-bold text-gray-900">Meu Perfil</h1>
        <p class="text-gray-600 mt-2">Atualize suas informações pessoais</p>
      </div>

      <!-- Formulário -->
      <div class="bg-white rounded-lg shadow-sm p-6">
        <form @submit.prevent="saveProfile" class="space-y-6">
          <!-- Seção de Informações Pessoais -->
          <div>
            <h2 class="text-lg font-semibold text-gray-900 mb-4">Informações Pessoais</h2>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Nome *</label>
                <input
                  v-model="form.first_name"
                  type="text"
                  required
                  class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                />
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Sobrenome *</label>
                <input
                  v-model="form.last_name"
                  type="text"
                  required
                  class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                />
              </div>
            </div>
          </div>

          <!-- Seção de Contato -->
          <div>
            <h2 class="text-lg font-semibold text-gray-900 mb-4">Informações de Contato</h2>
            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">E-mail *</label>
                <input
                  v-model="form.email"
                  type="email"
                  required
                  class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                />
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Telefone</label>
                <input
                  v-model="form.phone"
                  @input="applyPhoneMask"
                  type="tel"
                  placeholder="(00) 00000-0000"
                  maxlength="15"
                  class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                />
              </div>
            </div>
          </div>

          

          <!-- Seção de Segurança -->
          <div>
            <h2 class="text-lg font-semibold text-gray-900 mb-4">Alterar Senha</h2>
            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Senha Atual</label>
                <input
                  v-model="form.current_password"
                  type="password"
                  class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                />
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Nova Senha</label>
                <input
                  v-model="form.password"
                  type="password"
                  class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                />
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Confirmar Nova Senha</label>
                <input
                  v-model="form.password_confirmation"
                  type="password"
                  class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                />
              </div>
            </div>
          </div>

          <!-- Mensagens de erro e sucesso -->
          <div v-if="successMessage" class="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-lg flex items-center space-x-2">
            <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
            </svg>
            <span>{{ successMessage }}</span>
          </div>

          <div v-if="errors.general" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg flex items-center space-x-2">
            <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
            </svg>
            <span>{{ errors.general }}</span>
          </div>

          <!-- Botões de ação -->
          <div class="flex justify-end space-x-3 pt-6 border-t border-gray-200">
            <button
              type="button"
              @click="goBack"
              class="px-6 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition font-medium"
            >
              Cancelar
            </button>
            <button
              type="submit"
              :disabled="saving"
              class="px-6 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition font-medium disabled:opacity-50"
            >
              {{ saving ? 'Salvando...' : 'Salvar Alterações' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
import { navigateTo } from '../router.js'
import { useApi } from '../composables/useApi.js'
import { useInputMasks } from '../composables/useInputMasks.js'

export default {
  props: {
    user: {
      type: Object,
      required: true
    }
  },

  data() {
    return {
      form: {
        first_name: '',
        last_name: '',
        email: '',
        phone: '',
        current_password: '',
        password: '',
        password_confirmation: ''
      },
      saving: false,
      successMessage: '',
      errors: {},
      stateOptions: []
    }
  },

  mounted() {
    this.loadUserData()
    this.fetchProfile()
  },

  methods: {
    loadUserData() {
      this.form = {
        first_name: this.user.first_name || '',
        last_name: this.user.last_name || '',
        email: this.user.email || '',
        phone: this.user.phone || '',
        current_password: '',
        password: '',
        password_confirmation: ''
      }
    },

    async fetchProfile() {
      try {
        const { get } = useApi()
        const { data, error } = await get('/api/v1/me')
        
        if (error) return
        
        const userData = data
        this.form = {
          first_name: userData.first_name || '',
          last_name: userData.last_name || '',
          email: userData.email || '',
          phone: userData.phone || '',
          current_password: '',
          password: '',
          password_confirmation: ''
        }

        localStorage.setItem('user', JSON.stringify(userData))
      } catch (error) {
        console.error('Erro ao carregar perfil', error)
      }
    },

    async saveProfile() {
      this.saving = true
      this.errors = {}
      this.successMessage = ''

      try {
        const { put } = useApi()
        const payload = { ...this.form }

        // Remove senhas vazias do payload
        if (!payload.current_password) {
          delete payload.current_password
        }
        if (!payload.password) {
          delete payload.password
        }
        if (!payload.password_confirmation) {
          delete payload.password_confirmation
        }

        const { data, error } = await put('/api/v1/me', { user: payload })

        if (error) {
          const errorList = error.response?.data?.errors
          if (Array.isArray(errorList)) {
            this.errors.general = errorList.join(', ')
          } else if (typeof errorList === 'object') {
            const firstKey = Object.keys(errorList)[0]
            this.errors.general = errorList[firstKey]?.[0] || 'Erro ao salvar perfil'
          } else {
            this.errors.general = errorList || 'Erro ao salvar perfil'
          }
          return
        }

        // Atualiza o usuário no localStorage
        localStorage.setItem('user', JSON.stringify(data))

        this.successMessage = 'Perfil atualizado com sucesso!'
        setTimeout(() => {
          this.successMessage = ''
        }, 3000)
      } catch (err) {
        this.errors.general = 'Erro ao salvar perfil'
      } finally {
        this.saving = false
      }
    },

    goBack() {
      navigateTo('dashboard')
    }
  }
}
</script>
