<template>
  <div class="fixed inset-0 bg-gradient-to-br from-blue-50 to-indigo-100 overflow-y-auto z-50 pt-20 pb-12">
    <div class="flex items-center justify-center min-h-screen">
      <div class="w-full max-w-md px-4">
        <div class="bg-white rounded-2xl shadow-xl p-8 md:p-10">
        <div class="text-center mb-8">
          <h1 class="text-4xl font-bold text-gray-900">MyStay</h1>
          <p class="text-gray-600 mt-2">Crie sua conta</p>
        </div>

        <form @submit.prevent="handleRegister" class="space-y-4">
          <!-- Tenant Info -->
          <div class="border-b pb-4 mb-4">
            <h3 class="text-sm font-semibold text-gray-700 mb-3">Informações do Tenant</h3>
            
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Nome do Tenant</label>
              <input
                v-model="form.tenant.name"
                type="text"
                placeholder="Ex: Meu Imóvel"
                required
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div class="mt-3">
              <label class="block text-sm font-medium text-gray-700 mb-1">Master Code</label>
              <input
                v-model="form.tenant.master_code"
                type="text"
                placeholder="Ex: my-property-1"
                @input="validateMasterCode"
                required
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
              <p class="text-xs text-gray-500 mt-1">Apenas letras, números, hífen e underscore</p>
              <p v-if="masterCodeError" class="text-xs text-red-600 mt-1">{{ masterCodeError }}</p>
            </div>
          </div>

          <!-- User Info -->
          <div class="border-b pb-4 mb-4">
            <h3 class="text-sm font-semibold text-gray-700 mb-3">Seus Dados</h3>
            
              <div class="grid grid-cols-2 gap-3">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">Nome</label>
                  <input
                    v-model="form.user.first_name"
                    type="text"
                    placeholder="Seu nome"
                    required
                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">Sobrenome</label>
                  <input
                    v-model="form.user.last_name"
                    type="text"
                    placeholder="Seu sobrenome"
                    required
                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                  />
                </div>
              </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1 mt-3">Email</label>
              <input
                v-model="form.user.email"
                type="email"
                placeholder="seu@email.com"
                required
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mt-3 mb-1">Telefone</label>
              <input
                v-model="form.user.phone"
                type="tel"
                @input="masks.handlePhoneMaskInput"
                placeholder="(00) 00000-0000"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>
          </div>

          <!-- Password -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Senha</label>
            <input
              v-model="form.user.password"
              type="password"
              placeholder="Mínimo 6 caracteres"
              required
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Confirmar Senha</label>
            <input
              v-model="form.user.password_confirmation"
              type="password"
              placeholder="Confirme sua senha"
              required
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>

          <div v-if="error" class="bg-red-50 text-red-600 px-4 py-3 rounded-lg text-sm">
            {{ error }}
          </div>

          <button
            type="submit"
            :disabled="!isFormValid || loading"
            class="w-full bg-indigo-600 text-white py-2 rounded-lg font-semibold hover:bg-indigo-700 transition disabled:opacity-50"
          >
            {{ loading ? 'Criando conta...' : 'Criar Conta' }}
          </button>

          <div class="text-center text-sm mt-4">
            <span class="text-gray-600">Já tem uma conta? </span>
            <button type="button" @click="$emit('switch-to-login')" class="text-indigo-600 font-semibold hover:text-indigo-700">
              Entrar
            </button>
          </div>
        </form>
      </div>
    </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios'
import { useBrazilianMasks } from '../composables/useBrazilianMasks.js'

export default {
  emits: ['register-success', 'switch-to-login'],
  
  data() {
    return {
      loading: false,
      error: '',
      masterCodeError: '',
      masks: useBrazilianMasks(),
      form: {
        tenant: {
          name: '',
          master_code: ''
        },
        user: {
          email: '',
          phone: '',
          first_name: '',
          last_name: '',
          password: '',
          password_confirmation: ''
        }
      }
    }
  },

  computed: {
    isFormValid() {
      // Verificar se todos os campos obrigatórios estão preenchidos
      const tenantValid = this.form.tenant.name.trim() !== '' && 
                         this.form.tenant.master_code.trim() !== ''
      
      const userValid = this.form.user.first_name.trim() !== '' &&
                       this.form.user.last_name.trim() !== '' &&
                       this.form.user.email.trim() !== '' &&
                       this.form.user.password.trim() !== '' &&
                       this.form.user.password_confirmation.trim() !== ''
      
      // Verificar se não há erro no master code
      const noMasterCodeError = !this.masterCodeError
      
      // Verificar se as senhas coincidem
      const passwordsMatch = this.form.user.password === this.form.user.password_confirmation
      
      return tenantValid && userValid && noMasterCodeError && passwordsMatch
    }
  },

  methods: {
    validateMasterCode() {
      const masterCode = this.form.tenant.master_code
      
      // Limpar erro se o campo estiver vazio
      if (!masterCode) {
        this.masterCodeError = ''
        return
      }
      
      // Validar comprimento mínimo primeiro
      if (masterCode.length < 3) {
        this.masterCodeError = 'Master code deve ter pelo menos 3 caracteres'
        return
      }
      
      // Validar caracteres permitidos
      if (!/^[a-zA-Z0-9_-]+$/.test(masterCode)) {
        this.masterCodeError = 'Apenas letras, números, hífen e underscore são permitidos'
        return
      }
      
      // Se passou em todas as validações, limpar o erro
      this.masterCodeError = ''
    },

    async handleRegister() {
      this.loading = true
      this.error = ''

      if (this.form.user.password !== this.form.user.password_confirmation) {
        this.error = 'As senhas não coincidem'
        this.loading = false
        return
      }

      try {
        const response = await axios.post('/api/v1/tenants/register', {
          tenant: this.form.tenant,
          user: this.form.user
        })

        localStorage.setItem('tenantToken', response.data.tenantToken)
        localStorage.setItem('userToken', response.data.userToken)
        localStorage.setItem('tenant', JSON.stringify(response.data.tenant))
        localStorage.setItem('user', JSON.stringify(response.data.user))
        localStorage.setItem('masterCode', response.data.tenant.master_code)

        this.$emit('register-success', {
          tenant: response.data.tenant,
          user: response.data.user,
          tenantToken: response.data.tenantToken,
          userToken: response.data.userToken
        })
      } catch (err) {
        if (err.response?.data?.errors) {
          this.error = err.response.data.errors.join(', ')
        } else {
          this.error = 'Falha ao criar conta. Tente novamente.'
        }
      } finally {
        this.loading = false
      }
    }
  }
}
</script>
