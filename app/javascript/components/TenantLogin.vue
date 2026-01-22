<template>
  <div class="fixed inset-0 bg-gradient-to-br from-blue-50 to-indigo-100 overflow-y-auto z-50 pt-20 pb-12">
    <div class="flex items-center justify-center min-h-screen">
      <div class="w-full max-w-md px-4">
        <div class="bg-white rounded-2xl shadow-xl p-8 md:p-10">
        <div class="text-center mb-8">
          <h1 class="text-4xl font-bold text-gray-900">MyStay</h1>
          <p class="text-gray-600 mt-2">Acesse sua conta</p>
        </div>

        <form @submit.prevent="handleLogin" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Master Code do Tenant</label>
            <input
              v-model="form.master_code"
              type="text"
              placeholder="Ex: my-property-1"
              required
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
            <input
              v-model="form.email"
              type="email"
              placeholder="seu@email.com"
              required
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Senha</label>
            <input
              v-model="form.password"
              type="password"
              placeholder="Sua senha"
              required
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>

          <div v-if="error" class="bg-red-50 text-red-600 px-4 py-3 rounded-lg text-sm">
            {{ error }}
          </div>

          <button
            type="submit"
            :disabled="loading"
            class="w-full bg-indigo-600 text-white py-2 rounded-lg font-semibold hover:bg-indigo-700 transition disabled:opacity-50"
          >
            {{ loading ? 'Carregando...' : 'Entrar' }}
          </button>

          <div class="text-center text-sm mt-4">
            <span class="text-gray-600">Não tem uma conta? </span>
            <button type="button" @click="$emit('switch-to-register')" class="text-indigo-600 font-semibold hover:text-indigo-700">
              Criar Conta
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

export default {
  emits: ['login-success', 'switch-to-register'],
  
  data() {
    return {
      loading: false,
      error: '',
      form: {
        master_code: '',
        email: '',
        password: ''
      }
    }
  },

  methods: {
    async handleLogin() {
      this.loading = true
      this.error = ''

      try {
        const response = await axios.post('/api/v1/tenants/login', {
          master_code: this.form.master_code,
          email: this.form.email,
          password: this.form.password
        })

        localStorage.setItem('tenantToken', response.data.tenantToken)
        localStorage.setItem('userToken', response.data.userToken)
        localStorage.setItem('tenant', JSON.stringify(response.data.tenant))
        localStorage.setItem('user', JSON.stringify(response.data.user))
        localStorage.setItem('masterCode', response.data.tenant.master_code)

        this.$emit('login-success', {
          tenant: response.data.tenant,
          user: response.data.user,
          tenantToken: response.data.tenantToken,
          userToken: response.data.userToken
        })
      } catch (err) {
        this.error = err.response?.data?.error || 'Falha no login. Tente novamente.'
      } finally {
        this.loading = false
      }
    }
  }
}
</script>
