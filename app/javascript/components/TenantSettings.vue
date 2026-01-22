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
        <h1 class="text-3xl font-bold text-gray-900">Configurações do Tenant</h1>
        <p class="text-gray-600 mt-2">Edite as informações do seu espaço</p>
      </div>

      <!-- Formulário -->
      <div class="bg-white rounded-lg shadow-sm p-6">
        <form @submit.prevent="saveTenantSettings" class="space-y-6">
          <!-- Informações do Tenant -->
          <div>
            <h2 class="text-lg font-semibold text-gray-900 mb-4">Informações do Tenant</h2>
            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Nome do Tenant *</label>
                <input
                  v-model="form.name"
                  type="text"
                  required
                  class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                />
                <span v-if="errors.name" class="text-red-500 text-sm">{{ errors.name }}</span>
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Master Code *</label>
                <input
                  v-model="form.master_code"
                  type="text"
                  required
                  @input="validateMasterCode"
                  placeholder="Ex: my-property-1"
                  class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                  :class="{ 'border-red-500': masterCodeError }"
                />
                <p class="text-xs text-gray-500 mt-1">Apenas letras, números, hífen e underscore</p>
                <span v-if="masterCodeError" class="text-red-500 text-sm">{{ masterCodeError }}</span>
              </div>
            </div>
          </div>

          <!-- Mensagens -->
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
              :disabled="saving || !!masterCodeError"
              class="px-6 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition font-medium disabled:opacity-50 disabled:cursor-not-allowed"
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

export default {
  data() {
    return {
      form: {
        name: '',
        master_code: ''
      },
      saving: false,
      successMessage: '',
      masterCodeError: '',
      errors: {},
      originalMasterCode: ''
    }
  },

  mounted() {
    this.loadTenantData()
    // Validar o master_code carregado para garantir que não há erro ao abrir
    this.validateMasterCode()
  },

  methods: {
    loadTenantData() {
      const tenantData = localStorage.getItem('tenant')
      if (tenantData) {
        const tenant = JSON.parse(tenantData)
        this.form.name = tenant.name || ''
        this.form.master_code = tenant.master_code || ''
        this.originalMasterCode = tenant.master_code || ''
      }
    },

    validateMasterCode() {
      const masterCode = this.form.master_code

      if (!masterCode) {
        this.masterCodeError = ''
        return
      }

      if (masterCode.length < 3) {
        this.masterCodeError = 'Master code deve ter pelo menos 3 caracteres'
        return
      }

      if (!/^[a-zA-Z0-9_-]+$/.test(masterCode)) {
        this.masterCodeError = 'Apenas letras, números, hífen e underscore são permitidos'
        return
      }

      this.masterCodeError = ''
    },

    async saveTenantSettings() {
      this.saving = true
      this.errors = {}
      this.successMessage = ''

      // Validar master code antes de enviar
      this.validateMasterCode()
      if (this.masterCodeError) {
        this.saving = false
        return
      }

      try {
        const { put } = useApi()
        const { data, error } = await put('/api/v1/tenant', {
          tenant: {
            name: this.form.name,
            master_code: this.form.master_code
          }
        })

        if (error) {
          const errorList = error.response?.data?.errors
          if (Array.isArray(errorList)) {
            this.errors.general = errorList.join(', ')
          } else if (typeof errorList === 'object') {
            const firstKey = Object.keys(errorList)[0]
            this.errors.general = errorList[firstKey]?.[0] || 'Erro ao salvar configurações'
          } else {
            this.errors.general = errorList || 'Erro ao salvar configurações'
          }
          return
        }

        // Atualizar tenant no localStorage
        const updatedTenant = {
          ...JSON.parse(localStorage.getItem('tenant') || '{}'),
          name: data.name,
          master_code: data.master_code
        }
        localStorage.setItem('tenant', JSON.stringify(updatedTenant))
        localStorage.setItem('masterCode', data.master_code)

        // Atualizar a URL se o master_code foi alterado
        if (data.master_code !== this.originalMasterCode) {
          window.history.replaceState({}, document.title, `/${data.master_code}`)
        }

        this.originalMasterCode = data.master_code
        this.successMessage = 'Configurações atualizadas com sucesso!'
        
        setTimeout(() => {
          this.successMessage = ''
        }, 3000)
      } catch (err) {
        this.errors.general = 'Erro ao salvar configurações'
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
