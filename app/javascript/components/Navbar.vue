<template>
  <nav class="bg-white border-b border-gray-200 fixed top-0 left-0 right-0 z-50">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex justify-between items-center h-16">
        <!-- Logo e marca à esquerda -->
        <button @click="navigate('dashboard')" class="flex items-center group cursor-pointer">
          <div class="w-8 h-8 bg-gradient-to-br from-indigo-600 to-indigo-700 rounded-lg flex items-center justify-center text-white font-bold text-lg mr-3 group-hover:shadow-md transition-shadow">
            T
          </div>
          <span class="text-lg font-semibold text-gray-900 group-hover:text-indigo-600 transition-colors">TripDay</span>
        </button>

        <!-- Menu de navegação no centro (desktop) -->
        <div class="hidden lg:flex items-center space-x-1">
          <div class="relative group">
            <button
              @click="toggleCadastroDropdown"
              class="flex items-center space-x-1 text-gray-700 hover:text-indigo-600 px-4 py-2 rounded-lg text-sm font-medium transition group-hover:bg-gray-50"
            >
              <span>Cadastro</span>
              <svg
                class="w-4 h-4 transition-transform"
                :class="{ 'rotate-180': isCadastroDropdownOpen }"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
              </svg>
            </button>

            <transition
              enter-active-class="transition ease-out duration-100"
              enter-from-class="transform opacity-0 scale-95"
              enter-to-class="transform opacity-100 scale-100"
              leave-active-class="transition ease-in duration-75"
              leave-from-class="transform opacity-100 scale-100"
              leave-to-class="transform opacity-0 scale-95"
            >
              <div
                v-if="isCadastroDropdownOpen"
                class="absolute left-0 mt-2 w-44 bg-white rounded-lg shadow-lg py-2 z-10 border border-gray-100"
              >
                <button
                  @click="navigate('people')"
                  class="w-full text-left flex items-center px-4 py-2 text-sm text-gray-700 hover:bg-indigo-50 hover:text-indigo-600 transition"
                >
                  <i class="fa-solid fa-user text-gray-500 mr-3"></i>
                  Pessoas
                </button>
                <button
                  @click="navigate('users')"
                  class="w-full text-left flex items-center px-4 py-2 text-sm text-gray-700 hover:bg-indigo-50 hover:text-indigo-600 transition"
                >
                  <i class="fa-solid fa-users text-gray-500 mr-3"></i>
                  Usuários
                </button>
                <div class="border-t border-gray-100 my-2"></div>
                <button
                    @click="navigate('properties')"
                    class="w-full text-left flex items-center px-4 py-2 text-sm text-gray-700 hover:bg-indigo-50 hover:text-indigo-600 transition"
                  >
                    <i class="fa-solid fa-house text-gray-500 mr-3"></i>
                    Imóveis
                </button>
                <button
                  @click="navigate('service-types')"
                  class="w-full text-left flex items-center px-4 py-2 text-sm text-gray-700 hover:bg-indigo-50 hover:text-indigo-600 transition"
                >
                  <i class="fa-solid fa-list text-gray-500 mr-3"></i>
                  Tipos de Serviço
                </button>
                
              </div>
            </transition>
          </div>

          <button
            @click="navigate('bookings')"
            class="text-gray-700 hover:text-indigo-600 px-4 py-2 rounded-lg text-sm font-medium transition hover:bg-gray-50"
          >
            Hospedagens
          </button>

          <button
            @click="navigate('expenses')"
            class="text-gray-700 hover:text-indigo-600 px-4 py-2 rounded-lg text-sm font-medium transition hover:bg-gray-50"
          >
            Despesas
          </button>

          <button
            @click="navigate('analysis')"
            class="text-gray-700 hover:text-indigo-600 px-4 py-2 rounded-lg text-sm font-medium transition hover:bg-gray-50"
          >
            Análise
          </button>
        </div>

        <!-- Menu do usuário à direita -->
        <div class="flex items-center space-x-4">
          <div class="relative">
            <button
              @click="toggleDropdown"
              class="flex items-center space-x-2 text-gray-700 hover:text-indigo-600 focus:outline-none transition"
            >
              <div class="w-12 h-12 rounded-full overflow-hidden border-2 border-white bg-gradient-to-br from-indigo-500 to-indigo-600 flex items-center justify-center text-white font-semibold text-sm">
                <img v-if="userAvatar" :src="userAvatar" alt="Avatar" class="w-full h-full object-cover" style="min-width:100%;min-height:100%;object-fit:cover;object-position:center;" />
                <span v-else>{{ userInitials }}</span>
              </div>
              <span class="hidden sm:block text-sm font-medium truncate max-w-xs">{{ userName }}</span>
              <svg
                class="w-4 h-4 transition-transform hidden sm:block"
                :class="{ 'rotate-180': isDropdownOpen }"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
              </svg>
            </button>

            <!-- Dropdown do usuário -->
            <transition
              enter-active-class="transition ease-out duration-100"
              enter-from-class="transform opacity-0 scale-95"
              enter-to-class="transform opacity-100 scale-100"
              leave-active-class="transition ease-in duration-75"
              leave-from-class="transform opacity-100 scale-100"
              leave-to-class="transform opacity-0 scale-95"
            >
              <div
                v-if="isDropdownOpen"
                class="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-lg py-2 z-10 border border-gray-100"
              >
                <button
                  @click="navigate('profile')"
                  class="w-full text-left flex items-center px-4 py-2 text-sm text-gray-700 hover:bg-indigo-50 hover:text-indigo-600 transition"
                >
                  <svg class="w-4 h-4 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                  </svg>
                  <span>Perfil</span>
                </button>
                <button
                  @click="navigate('tenant-settings')"
                  class="w-full text-left flex items-center px-4 py-2 text-sm text-gray-700 hover:bg-indigo-50 hover:text-indigo-600 transition"
                >
                  <svg class="w-4 h-4 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                  </svg>
                  <span>Configurações</span>
                </button>
                <div class="border-t border-gray-100 my-1"></div>
                <button
                  @click="logout"
                  class="w-full text-left flex items-center px-4 py-2 text-sm text-red-600 hover:bg-red-50 transition"
                >
                  <svg class="w-4 h-4 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                  </svg>
                  <span>Sair</span>
                </button>
              </div>
            </transition>
          </div>
        </div>
      </div>
    </div>

    <!-- Menu mobile -->
    <div class="lg:hidden border-t border-gray-200">
      <div class="px-4 pt-2 pb-3 space-y-1">
        <div>
          <button
            @click="toggleMobileCadastroDropdown"
            class="w-full flex items-center justify-between text-gray-700 hover:text-indigo-600 hover:bg-indigo-50 px-3 py-2 rounded-lg text-sm font-medium transition"
          >
            <span>Cadastro</span>
            <svg
              class="w-4 h-4 transition-transform"
              :class="{ 'rotate-180': isMobileCadastroOpen }"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
            </svg>
          </button>
          <div v-if="isMobileCadastroOpen" class="pl-4 space-y-1">
            <button
              @click="navigate('people')"
              class="w-full text-left flex items-center text-gray-600 hover:text-indigo-600 hover:bg-indigo-50 px-3 py-2 rounded-lg text-sm transition"
            >
              <i class="fa-solid fa-user text-gray-500 mr-2"></i>
              Pessoas
            </button>
            <button
              @click="navigate('users')"
              class="w-full text-left flex items-center text-gray-600 hover:text-indigo-600 hover:bg-indigo-50 px-3 py-2 rounded-lg text-sm transition"
            >
              <i class="fa-solid fa-users text-gray-500 mr-2"></i>
              Usuários
            </button>
            <div class="border-t border-gray-200 my-2"></div>
            <button
              @click="navigate('service-types')"
              class="w-full text-left flex items-center text-gray-600 hover:text-indigo-600 hover:bg-indigo-50 px-3 py-2 rounded-lg text-sm transition"
            >
              <i class="fa-solid fa-list text-gray-500 mr-2"></i>
              Tipos de Serviço
            </button>
            <button
              @click="navigate('properties')"
              class="w-full text-left flex items-center text-gray-600 hover:text-indigo-600 hover:bg-indigo-50 px-3 py-2 rounded-lg text-sm transition"
            >
              <i class="fa-solid fa-house text-gray-500 mr-2"></i>
              Imóveis
            </button>
            
          </div>
        </div>
        <button
          @click="navigate('bookings')"
          class="w-full text-left block text-gray-700 hover:text-indigo-600 hover:bg-indigo-50 px-3 py-2 rounded-lg text-sm font-medium transition"
        >
          Hospedagens
        </button>
        <button
          @click="navigate('expenses')"
          class="w-full text-left block text-gray-700 hover:text-indigo-600 hover:bg-indigo-50 px-3 py-2 rounded-lg text-sm font-medium transition"
        >
          Despesas
        </button>
        <button
          @click="navigate('analysis')"
          class="w-full text-left block text-gray-700 hover:text-indigo-600 hover:bg-indigo-50 px-3 py-2 rounded-lg text-sm font-medium transition"
        >
          Análise
        </button>
      </div>
    </div>
  </nav>
</template>

<script>
import { navigateTo } from '../router.js'

export default {
  props: {
    user: {
      type: Object,
      required: true
    }
  },

  data() {
    return {
      isDropdownOpen: false,
      isCadastroDropdownOpen: false,
      isMobileCadastroOpen: false
    }
  },

  computed: {
    userName() {
      if (this.user.first_name && this.user.last_name) {
        return `${this.user.first_name} ${this.user.last_name}`
      }
      return this.user.email
    },

    userInitials() {
      if (this.user.first_name && this.user.last_name) {
        return `${this.user.first_name[0]}${this.user.last_name[0]}`.toUpperCase()
      }
      return this.user.email[0]?.toUpperCase() || ''
    },

    userAvatar() {
      return this.user.profile_image || ''
    }
  },

  mounted() {
    document.addEventListener('click', this.handleClickOutside)
  },

  beforeUnmount() {
    document.removeEventListener('click', this.handleClickOutside)
  },

  methods: {
    navigate(route) {
      navigateTo(route)
      this.isCadastroDropdownOpen = false
      this.isMobileCadastroOpen = false
      this.isDropdownOpen = false
    },

    toggleDropdown() {
      this.isDropdownOpen = !this.isDropdownOpen
    },

    toggleCadastroDropdown() {
      this.isCadastroDropdownOpen = !this.isCadastroDropdownOpen
    },

    toggleMobileCadastroDropdown() {
      this.isMobileCadastroOpen = !this.isMobileCadastroOpen
    },

    handleClickOutside(event) {
      // Verifica se o clique foi fora dos dropdowns
      const navElement = this.$el
      
      // Se clicou dentro da navbar, não fecha nada
      if (!navElement || navElement.contains(event.target)) {
        return
      }
      
      // Fecha todos os dropdowns se clicou realmente fora
      this.isDropdownOpen = false
      this.isCadastroDropdownOpen = false
      this.isMobileCadastroOpen = false
    },

    logout() {
      localStorage.removeItem('token')
      localStorage.removeItem('user')
      window.location.reload()
    }
  }
}
</script>
