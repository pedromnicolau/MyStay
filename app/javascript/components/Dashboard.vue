<template>
  <div class="min-h-screen bg-gray-50">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900 mb-2">Dashboard</h1>
        <p class="text-gray-600">Bem-vindo ao sistema de gerenciamento MyStay</p>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <div class="bg-white rounded-lg shadow-sm p-6 border-l-4 border-indigo-600">
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm font-medium text-gray-600 uppercase">Clientes</p>
              <p class="text-3xl font-bold text-gray-900 mt-2">{{ stats.customers }}</p>
            </div>
            <div class="bg-indigo-100 rounded-full p-3">
              <svg class="w-8 h-8 text-indigo-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
              </svg>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-lg shadow-sm p-6 border-l-4 border-green-600">
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm font-medium text-gray-600 uppercase">Imóveis</p>
              <p class="text-3xl font-bold text-gray-900 mt-2">{{ stats.properties }}</p>
            </div>
            <div class="bg-green-100 rounded-full p-3">
              <svg class="w-8 h-8 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
              </svg>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-lg shadow-sm p-6 border-l-4 border-yellow-600">
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm font-medium text-gray-600 uppercase">Corretores</p>
              <p class="text-3xl font-bold text-gray-900 mt-2">{{ stats.sellers }}</p>
            </div>
            <div class="bg-yellow-100 rounded-full p-3">
              <svg class="w-8 h-8 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
              </svg>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-lg shadow-sm p-6 border-l-4 border-purple-600">
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm font-medium text-gray-600 uppercase">Faxineiras</p>
              <p class="text-3xl font-bold text-gray-900 mt-2">{{ stats.cleaners }}</p>
            </div>
            <div class="bg-purple-100 rounded-full p-3">
              <svg class="w-8 h-8 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z" />
              </svg>
            </div>
          </div>
        </div>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div class="bg-white rounded-lg shadow-sm p-6">
          <h2 class="text-xl font-semibold text-gray-900 mb-4">Acesso Rápido</h2>
          <div class="space-y-3">
            <button
              @click="navigate('customers')"
              class="w-full flex items-center justify-between p-4 bg-gray-50 hover:bg-indigo-50 rounded-lg transition"
            >
              <span class="font-medium text-gray-900">Gerenciar Clientes</span>
              <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
              </svg>
            </button>
            <button
              @click="navigate('properties')"
              class="w-full flex items-center justify-between p-4 bg-gray-50 hover:bg-indigo-50 rounded-lg transition"
            >
              <span class="font-medium text-gray-900">Gerenciar Imóveis</span>
              <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
              </svg>
            </button>
            <button
              @click="navigate('sellers')"
              class="w-full flex items-center justify-between p-4 bg-gray-50 hover:bg-indigo-50 rounded-lg transition"
            >
              <span class="font-medium text-gray-900">Gerenciar Corretores</span>
              <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
              </svg>
            </button>
            <button
              @click="navigate('cleaners')"
              class="w-full flex items-center justify-between p-4 bg-gray-50 hover:bg-indigo-50 rounded-lg transition"
            >
              <span class="font-medium text-gray-900">Gerenciar Faxineiras</span>
              <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
              </svg>
            </button>
          </div>
        </div>

        <div class="bg-white rounded-lg shadow-sm p-6">
          <h2 class="text-xl font-semibold text-gray-900 mb-4">Informações do Sistema</h2>
          <div class="space-y-4">
            <div class="flex items-start">
              <div class="bg-blue-100 rounded-full p-2 mr-3">
                <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <div>
                <h3 class="font-medium text-gray-900">Sistema Atualizado</h3>
                <p class="text-sm text-gray-600 mt-1">Versão 1.0.0 - Todos os módulos funcionando corretamente</p>
              </div>
            </div>
            <div class="flex items-start">
              <div class="bg-green-100 rounded-full p-2 mr-3">
                <svg class="w-5 h-5 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <div>
                <h3 class="font-medium text-gray-900">Backup Realizado</h3>
                <p class="text-sm text-gray-600 mt-1">Último backup há 2 horas</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios'
import { navigateTo } from '../router.js'

export default {
  data() {
    return {
      stats: {
        customers: 0,
        properties: 0,
        sellers: 0,
        cleaners: 0
      }
    }
  },

  mounted() {
    this.loadStats()
  },

  methods: {
    navigate(route) {
      navigateTo(route)
    },

    async loadStats() {
      try {
        const userToken = localStorage.getItem('userToken')
        const tenantToken = localStorage.getItem('tenantToken')
        const headers = {
          Authorization: `Bearer ${userToken}`,
          'Tenant-Authorization': `Bearer ${tenantToken}`
        }

        const [customersRes, sellersRes, cleanersRes, propertiesRes] = await Promise.all([
          axios.get('/api/v1/people?type=Customer', { headers }),
          axios.get('/api/v1/people?type=Seller', { headers }),
          axios.get('/api/v1/people?type=Cleaner', { headers }),
          axios.get('/api/v1/properties', { headers })
        ])

        this.stats = {
          customers: Array.isArray(customersRes.data) ? customersRes.data.filter(item => item && item.id).length : 0,
          sellers: Array.isArray(sellersRes.data) ? sellersRes.data.filter(item => item && item.id).length : 0,
          cleaners: Array.isArray(cleanersRes.data) ? cleanersRes.data.filter(item => item && item.id).length : 0,
          properties: Array.isArray(propertiesRes.data) ? propertiesRes.data.filter(item => item && item.id).length : 0
        }
      } catch (err) {
        console.error('Error loading stats:', err)
      }
    }
  }
}
</script>
