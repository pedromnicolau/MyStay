<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Botão Voltar alinhado com Navbar (fora do fluxo de layout) -->
    <div class="fixed max-w-7xl w-full px-4 sm:px-6 lg:px-8 pt-8 left-0 right-0 mx-auto z-40">
      <button @click="goBack" class="flex items-center space-x-2 text-indigo-600 hover:text-indigo-700 transition">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
        </svg>
        <span>Voltar</span>
      </button>
    </div>

    <!-- Conteúdo principal centralizado -->
    <div class="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <!-- Header -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900">Meu Perfil</h1>
        <p class="text-gray-600 mt-2">Atualize suas informações pessoais</p>
      </div>

      <!-- Formulário -->
      <div class="bg-white rounded-lg shadow-sm p-6">
        <form @submit.prevent="saveProfile" class="space-y-6">
          <!-- Seção de Foto de Perfil -->
          <div>
            <ProfilePhotoUpload 
              v-model="form.profile_image"
              :name="`${form.first_name} ${form.last_name}`"
              @upload-success="handlePhotoUploadSuccess"
              @upload-error="handlePhotoUploadError"
            />
          </div>

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
import ProfilePhotoUpload from './ProfilePhotoUpload.vue'

const { applyPhoneMask } = useInputMasks()

export default {
  components: {
    ProfilePhotoUpload
  },
  emits: ['user-updated'],
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
        profile_image: '',
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
        profile_image: this.user.profile_image || '',
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
          profile_image: userData.profile_image || '',
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
        const { put, upload } = useApi()
        const formData = new FormData()

        // Adicionar dados do usuário
        formData.append('user[first_name]', this.form.first_name)
        formData.append('user[last_name]', this.form.last_name)
        formData.append('user[email]', this.form.email)
        formData.append('user[phone]', this.form.phone)

        // Adicionar senhas se fornecidas
        if (this.form.current_password) {
          formData.append('user[current_password]', this.form.current_password)
        }
        if (this.form.password) {
          formData.append('user[password]', this.form.password)
        }
        if (this.form.password_confirmation) {
          formData.append('user[password_confirmation]', this.form.password_confirmation)
        }

        // Converter Data URL para Blob e adicionar à foto
        if (this.form.profile_image && this.form.profile_image.startsWith('data:')) {
          console.log('Convertendo Data URL para Blob...')
          const blob = await this.dataUrlToBlob(this.form.profile_image)
          console.log('Blob criado com sucesso:', blob)
          formData.append('user[profile_image]', blob, 'profile.jpg')
          console.log('Blob adicionado ao FormData')
        } else if (this.form.profile_image) {
          console.log('Foto não é Data URL (pode ser URL HTTP já existente):', this.form.profile_image.substring(0, 50))
        }

        console.log('Enviando PATCH para /api/v1/me com FormData')
        const { data, error } = await upload('/api/v1/me', formData)

        if (error) {
          console.error('Erro ao salvar perfil:', error)
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

        console.log('Resposta do servidor:', data)
        localStorage.setItem('user', JSON.stringify(data))
        this.form = {
          first_name: data.first_name || '',
          last_name: data.last_name || '',
          email: data.email || '',
          phone: data.phone || '',
          profile_image: data.profile_image || '',
          current_password: '',
          password: '',
          password_confirmation: ''
        }
        this.$emit('user-updated', data)

        this.successMessage = 'Perfil atualizado com sucesso!'
        setTimeout(() => {
          this.successMessage = ''
        }, 3000)
      } catch (err) {
        this.errors.general = 'Erro ao salvar perfil'
        console.error('Erro ao salvar perfil:', err)
      } finally {
        this.saving = false
      }
    },

    async dataUrlToBlob(dataUrl) {
      const response = await fetch(dataUrl)
      return await response.blob()
    },

    handlePhotoUploadSuccess(payload) {
      if (payload.user) {
        this.form.profile_image = payload.user.profile_image || payload.url || ''
        this.$emit('user-updated', payload.user)
      }
    },

    handlePhotoUploadError(error) {
      this.errors.photo = 'Erro ao processar foto de perfil'
      console.error('Erro ao fazer upload da foto:', error)
    },

    applyPhoneMask(e) {
      this.form.phone = applyPhoneMask(e.target.value)
    },

    goBack() {
      navigateTo('dashboard')
    }
  }
}
</script>
