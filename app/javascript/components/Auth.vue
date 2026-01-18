<template>
  <div class="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center p-4">
    <div class="w-full max-w-md">
      <div class="bg-white rounded-2xl shadow-xl p-8 md:p-10">
        <div class="text-center mb-8">
          <h1 class="text-4xl font-bold text-gray-900">MyStay</h1>
          <p class="text-gray-600 mt-2">Professional Stay Management</p>
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
            Sign In
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
            Sign Up
          </button>
        </div>

        <form @submit.prevent="isLogin ? handleLogin() : handleRegister()" class="space-y-4">
          <div v-if="!isLogin" class="grid grid-cols-2 gap-4">
            <input
              v-model="form.first_name"
              type="text"
              placeholder="First Name"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
            <input
              v-model="form.last_name"
              type="text"
              placeholder="Last Name"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>

          <input
            v-model="form.email"
            type="email"
            placeholder="Email Address"
            required
            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
          />

          <input
            v-model="form.password"
            type="password"
            placeholder="Password"
            required
            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
          />

          <div v-if="!isLogin" class="grid grid-cols-2 gap-4">
            <input
              v-model="form.phone"
              type="tel"
              placeholder="Phone"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
            <input
              v-model="form.country"
              type="text"
              placeholder="Country"
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
            {{ loading ? 'Loading...' : (isLogin ? 'Sign In' : 'Create Account') }}
          </button>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  data() {
    return {
      isLogin: true,
      loading: false,
      error: '',
      form: {
        email: '',
        password: '',
        first_name: '',
        last_name: '',
        phone: '',
        country: ''
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
        this.error = err.response?.data?.error || 'Login failed. Please try again.'
      } finally {
        this.loading = false
      }
    },

    async handleRegister() {
      this.loading = true
      this.error = ''

      try {
        const response = await axios.post('/api/v1/auth/register', {
          user: {
            email: this.form.email,
            password: this.form.password,
            first_name: this.form.first_name,
            last_name: this.form.last_name,
            phone: this.form.phone,
            country: this.form.country
          }
        })

        localStorage.setItem('token', response.data.token)
        localStorage.setItem('user', JSON.stringify(response.data.user))
        this.$emit('login', response.data.user)
      } catch (err) {
        if (err.response?.data?.errors) {
          this.error = err.response.data.errors.join(', ')
        } else {
          this.error = 'Registration failed. Please try again.'
        }
      } finally {
        this.loading = false
      }
    },

    resetForm() {
      this.form = {
        email: '',
        password: '',
        first_name: '',
        last_name: '',
        phone: '',
        country: ''
      }
    }
  }
}
</script>
