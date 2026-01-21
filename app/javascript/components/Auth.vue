<template>
  <div class="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center p-4">
    <div class="w-full max-w-md">
      <div class="bg-white rounded-2xl shadow-xl p-8 md:p-10">
        <div class="text-center mb-8">
          <h1 class="text-4xl font-bold text-gray-900">MyStay</h1>
          <p class="text-gray-600 mt-2">Gerenciamento Profissional de Estadias</p>
        </div>

        <div class="mb-6 flex gap-2">
          <button
            @click="isLogin = true"
            :class="[
              'flex-1 py-2 px-4 rounded-lg font-semibold transition',
              isLogin 
                ? 'bg-indigo-600 text-white'
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            ]"
          >
            Entrar
          </button>
          <button
            @click="isLogin = false"
            :class="[
              'flex-1 py-2 px-4 rounded-lg font-semibold transition',
              !isLogin 
                ? 'bg-indigo-600 text-white'
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            ]"
          >
            Cadastro
          </button>
        </div>

        <form @submit.prevent="isLogin ? handleLogin() : handleRegister()" class="space-y-4">
          <div v-if="!isLogin" class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Nome</label>
              <input
                v-model="form.first_name"
                type="text"
                placeholder="Nome"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Sobrenome</label>
              <input
                v-model="form.last_name"
                type="text"
                placeholder="Sobrenome"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">E-mail</label>
            <input
              v-model="form.email"
              type="email"
              placeholder="Endereço de E-mail"
              required
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>

          <div v-if="!isLogin">
            <label class="block text-sm font-medium text-gray-700 mb-1">Telefone</label>
            <input
              v-model="form.phone"
              type="tel"
              inputmode="numeric"
              @input="masks.handlePhoneMaskInput"
              placeholder="(00) 00000-0000"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>

          <div v-if="!isLogin">
            <label class="block text-sm font-medium text-gray-700 mb-1">CPF</label>
            <input
              v-model="form.cpf"
              type="text"
              inputmode="numeric"
              @input="masks.handleCpfMaskInput"
              placeholder="000.000.000-00"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Senha</label>
            <input
              v-model="form.password"
              type="password"
              placeholder="Senha"
              required
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>

          <div v-if="!isLogin">
            <label class="block text-sm font-medium text-gray-700 mb-1">Confirmar Senha</label>
            <input
              v-model="form.password_confirmation"
              type="password"
              placeholder="Confirmar Senha"
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
            {{ loading ? 'Carregando...' : (isLogin ? 'Entrar' : 'Criar Conta') }}
          </button>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios'
import { useBrazilianMasks } from '../composables/useBrazilianMasks.js'

export default {
  data() {
    return {
      isLogin: true,
      loading: false,
      error: '',
      masks: useBrazilianMasks(),
      form: {
        email: '',
        password: '',
        password_confirmation: '',
        first_name: '',
        last_name: '',
        phone: '',
        cpf: ''
      }
    }
  },

  methods: {
    async handleLogin() {
      this.loading = true
      this.error = ''

      try {
        const response = await axios.post('/api/v1/auth/login', {
          email: this.form.email,
          password: this.form.password
        })

        localStorage.setItem('token', response.data.token)
        localStorage.setItem('user', JSON.stringify(response.data.user))
        this.$emit('login', response.data.user)
      } catch (err) {
        this.error = err.response?.data?.error || 'Falha no login. Tente novamente.'
      } finally {
        this.loading = false
      }
    },

    async handleRegister() {
      this.loading = true
      this.error = ''

      try {
        if (this.form.password !== this.form.password_confirmation) {
          this.error = 'As senhas não coincidem.'
          this.loading = false
          return
        }
        const response = await axios.post('/api/v1/auth/register', {
          user: {
            email: this.form.email,
            password: this.form.password,
            password_confirmation: this.form.password_confirmation,
            first_name: this.form.first_name,
            last_name: this.form.last_name,
            phone: this.form.phone,
            cpf: this.form.cpf
          }
        })

        localStorage.setItem('token', response.data.token)
        localStorage.setItem('user', JSON.stringify(response.data.user))
        this.$emit('login', response.data.user)
      } catch (err) {
        if (err.response?.data?.errors) {
          this.error = err.response.data.errors.join(', ')
        } else {
          this.error = 'Falha no cadastro. Tente novamente.'
        }
      } finally {
        this.loading = false
      }
    },

    resetForm() {
      this.form = {
        email: '',
        password: '',
        password_confirmation: '',
        first_name: '',
        last_name: '',
        phone: '',
        cpf: ''
      }
    }
  }
}
</script>
