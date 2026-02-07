<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Navbar -->
    <nav class="bg-white border-b border-gray-200 fixed top-0 left-0 right-0 z-50">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center h-16">
          <button @click="goToHome" class="flex items-center hover:opacity-80 transition-opacity cursor-pointer">
            <div class="w-8 h-8 bg-gradient-to-br from-indigo-600 to-indigo-700 rounded-lg flex items-center justify-center text-white font-bold text-lg mr-3">
              M
            </div>
            <span class="text-lg font-semibold text-gray-900">TripDay</span>
          </button>
          <div class="flex items-center gap-3">
            <button @click="activeModal = 'login'" class="text-indigo-600 font-semibold px-4 py-2 hover:bg-indigo-50 rounded-lg">
              Entrar
            </button>
            <button @click="activeModal = 'register'" class="bg-indigo-600 text-white font-semibold px-4 py-2 rounded-lg hover:bg-indigo-700">
              Criar Conta
            </button>
          </div>
        </div>
      </div>
    </nav>

    <!-- Property Showcase -->
    <PropertyShowcase />

    <!-- Login Modal -->
    <div v-if="showLoginModal" class="fixed inset-0 bg-black bg-opacity-50 z-40 flex items-center justify-center p-4">
      <div class="relative">
        <button @click="activeModal = null" class="absolute -top-10 right-0 text-white font-bold text-lg hover:text-gray-200">
          ✕ Fechar
        </button>
        <TenantLogin 
          key="login"
          @login-success="handleLoginSuccess"
          @switch-to-register="switchToRegister"
        />
      </div>
    </div>

    <!-- Register Modal -->
    <div v-if="showRegisterModal" class="fixed inset-0 bg-black bg-opacity-50 z-40 flex items-center justify-center p-4">
      <div class="relative">
        <button @click="activeModal = null" class="absolute -top-10 right-0 text-white font-bold text-lg hover:text-gray-200">
          ✕ Fechar
        </button>
        <TenantRegister 
          key="register"
          @register-success="handleRegisterSuccess"
          @switch-to-login="switchToLogin"
        />
      </div>
    </div>
  </div>
</template>

<script>
import TenantLogin from './TenantLogin.vue'
import TenantRegister from './TenantRegister.vue'
import PropertyShowcase from './PropertyShowcase.vue'

export default {
  components: { TenantLogin, TenantRegister, PropertyShowcase },
  emits: ['auth-success'],
  
  data() {
    return {
      activeModal: null // 'login', 'register', ou null
    }
  },
  
  computed: {
    showLoginModal() {
      return this.activeModal === 'login'
    },
    showRegisterModal() {
      return this.activeModal === 'register'
    }
  },

  methods: {
    handleLoginSuccess(data) {
      const masterCode = data.tenant.master_code
      window.history.replaceState({}, document.title, `/${masterCode}`)
      this.$emit('auth-success', data)
    },

    handleRegisterSuccess(data) {
      const masterCode = data.tenant.master_code
      window.history.replaceState({}, document.title, `/${masterCode}`)
      this.$emit('auth-success', data)
    },

    switchToRegister() {
      this.activeModal = 'register'
    },

    switchToLogin() {
      this.activeModal = 'login'
    },

    goToHome() {
      this.activeModal = null
      window.scrollTo({ top: 0, behavior: 'smooth' })
    }
  }
}
</script>
