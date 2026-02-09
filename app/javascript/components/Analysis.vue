<template>
  <div class="min-h-screen bg-gray-50">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div class="mb-6">
        <h1 class="text-3xl font-bold text-gray-900">Análise Financeira</h1>
        <p class="text-gray-600 mt-1">Análise de receitas e despesas baseada nas hospedagens</p>
      </div>

      <div class="bg-white rounded-lg shadow-sm p-6 mb-6">
        <h2 class="text-lg font-semibold text-gray-900 mb-4">Filtros</h2>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Imóvel</label>
            <select
              v-model="filters.propertyId"
              @change="loadBookings"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            >
              <option value="">Todos os imóveis</option>
              <option v-for="property in properties" :key="property.id" :value="property.id">
                {{ property.name }}
              </option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Data Início *</label>
            <input
              v-model="filters.startDate"
              type="date"
              required
              @change="loadBookings"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Data Fim</label>
            <input
              v-model="filters.endDate"
              type="date"
              @change="loadBookings"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>
        </div>
      </div>

      <div v-if="loading" class="flex justify-center items-center h-64">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600"></div>
      </div>

      <div v-else>
        <!-- Cards de Resumo -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <!-- A Receber -->
          <div class="bg-white rounded-lg shadow-sm p-6 border-l-4 border-green-600">
            <div class="flex items-center justify-between mb-4">
              <div>
                <p class="text-sm font-medium text-gray-600 uppercase">Total a Receber</p>
                <p class="text-xs text-gray-500 mt-1">De hóspedes</p>
              </div>
              <div class="bg-green-100 rounded-full p-3">
                <svg class="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                </svg>
              </div>
            </div>
            <p class="text-3xl font-bold text-gray-900">{{ formatCurrency(totals.totalDue) }}</p>
            <div class="mt-3 pt-3 border-t border-gray-100">
              <p class="text-sm text-gray-600">Recebido: <span class="font-semibold text-green-600">{{ formatCurrency(totals.totalReceived) }}</span></p>
              <p class="text-sm text-gray-600 mt-1">Saldo: <span class="font-semibold text-orange-600">{{ formatCurrency(totals.balanceDue) }}</span></p>
            </div>
          </div>

          <!-- A Pagar -->
          <div class="bg-white rounded-lg shadow-sm p-6 border-l-4 border-red-600">
            <div class="flex items-center justify-between mb-4">
              <div>
                <p class="text-sm font-medium text-gray-600 uppercase">Total a Pagar</p>
                <p class="text-xs text-gray-500 mt-1">Corretores e faxineiras</p>
              </div>
              <div class="bg-red-100 rounded-full p-3">
                <svg class="w-6 h-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 12H4" />
                </svg>
              </div>
            </div>
            <p class="text-3xl font-bold text-gray-900">{{ formatCurrency(totals.totalPayable) }}</p>
            <div class="mt-3 pt-3 border-t border-gray-100">
              <p class="text-sm text-gray-600">Pago: <span class="font-semibold text-green-600">{{ formatCurrency(totals.totalPaid) }}</span></p>
              <p class="text-sm text-gray-600 mt-1">Saldo: <span class="font-semibold text-orange-600">{{ formatCurrency(totals.balancePayable) }}</span></p>
            </div>
          </div>

          <!-- Balanço -->
          <div class="bg-white rounded-lg shadow-sm p-6 border-l-4" :class="balance >= 0 ? 'border-indigo-600' : 'border-yellow-600'">
            <div class="flex items-center justify-between mb-4">
              <div>
                <p class="text-sm font-medium text-gray-600 uppercase">Balanço</p>
                <p class="text-xs text-gray-500 mt-1">Receitas - Despesas</p>
              </div>
              <div class="rounded-full p-3" :class="balance >= 0 ? 'bg-indigo-100' : 'bg-yellow-100'">
                <svg class="w-6 h-6" :class="balance >= 0 ? 'text-indigo-600' : 'text-yellow-600'" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z" />
                </svg>
              </div>
            </div>
            <p class="text-3xl font-bold" :class="balance >= 0 ? 'text-indigo-600' : 'text-yellow-600'">
              {{ formatCurrency(balance) }}
            </p>
            <p class="text-sm mt-3 pt-3 border-t border-gray-100" :class="balance >= 0 ? 'text-green-600' : 'text-yellow-600'">
              {{ balance >= 0 ? '✓ Positivo' : '⚠ Atenção ao fluxo' }}
            </p>
          </div>
        </div>

        <!-- Tabela de Hospedagens -->
        <div class="bg-white rounded-lg shadow-sm overflow-hidden mb-8">
          <div class="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
            <h2 class="text-lg font-semibold text-gray-900">Detalhamento por Hospedagem</h2>
            <div class="flex items-center space-x-2">
              <button
                @click="filterType = 'all'"
                :class="filterType === 'all' ? 'bg-indigo-100 text-indigo-700' : 'bg-gray-100 text-gray-600'"
                class="px-3 py-1 rounded-md text-sm font-medium transition"
              >
                Todas
              </button>
              <button
                @click="filterType = 'booking'"
                :class="filterType === 'booking' ? 'bg-indigo-100 text-indigo-700' : 'bg-gray-100 text-gray-600'"
                class="px-3 py-1 rounded-md text-sm font-medium transition"
              >
                Hospedagens
              </button>
              <button
                @click="filterType = 'cleaning'"
                :class="filterType === 'cleaning' ? 'bg-emerald-100 text-emerald-700' : 'bg-gray-100 text-gray-600'"
                class="px-3 py-1 rounded-md text-sm font-medium transition"
              >
                Faxinas
              </button>
            </div>
          </div>

          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Tipo</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Hóspede/Faxineira</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Imóvel</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Check-in</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Check-out</th>
                  <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">A Receber</th>
                  <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">A Pagar</th>
                  <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Margem</th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <tr v-for="booking in filteredBookings" :key="booking.id" class="hover:bg-gray-50">
                  <td class="px-6 py-4 whitespace-nowrap">
                    <span
                      v-if="booking.type === 'Service'"
                      class="text-xs px-2 py-1 rounded-full bg-emerald-100 text-emerald-800 font-medium"
                    >
                      Faxina
                    </span>
                    <span
                      v-else
                      class="text-xs px-2 py-1 rounded-full bg-indigo-100 text-indigo-800 font-medium"
                    >
                      Hospedagem
                    </span>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {{ booking.guest_name }}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                    {{ booking.property_name }}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                    {{ formatDate(booking.check_in_date) }}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                    {{ formatDate(booking.check_out_date) }}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-right font-semibold text-green-600">
                    {{ formatCurrency(booking.total_due || 0) }}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-right font-semibold text-red-600">
                    {{ formatCurrency(booking.total_payable || 0) }}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-right font-semibold" :class="getMarginColor(booking)">
                    {{ formatCurrency(calculateMargin(booking)) }}
                  </td>
                </tr>
                <tr v-if="filteredBookings.length === 0">
                  <td colspan="8" class="px-6 py-12 text-center text-gray-500">
                    Nenhuma hospedagem encontrada
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <!-- Resumo por Período -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <!-- Gráfico de Pizza (simulado com barras) -->
          <div class="bg-white rounded-lg shadow-sm p-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">Distribuição de Valores</h3>
            <div class="space-y-4">
              <div>
                <div class="flex justify-between items-center mb-2">
                  <span class="text-sm font-medium text-gray-600">Receitas (A Receber)</span>
                  <span class="text-sm font-semibold text-green-600">{{ formatCurrency(totals.totalDue) }}</span>
                </div>
                <div class="w-full bg-gray-200 rounded-full h-3">
                  <div class="bg-green-600 h-3 rounded-full" :style="{ width: getPercentage(totals.totalDue) + '%' }"></div>
                </div>
              </div>
              <div>
                <div class="flex justify-between items-center mb-2">
                  <span class="text-sm font-medium text-gray-600">Despesas (A Pagar)</span>
                  <span class="text-sm font-semibold text-red-600">{{ formatCurrency(totals.totalPayable) }}</span>
                </div>
                <div class="w-full bg-gray-200 rounded-full h-3">
                  <div class="bg-red-600 h-3 rounded-full" :style="{ width: getPercentage(totals.totalPayable) + '%' }"></div>
                </div>
              </div>
            </div>
          </div>

          <!-- Estatísticas Adicionais -->
          <div class="bg-white rounded-lg shadow-sm p-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">Estatísticas</h3>
            <div class="space-y-3">
              <div class="flex justify-between items-center py-2 border-b border-gray-100">
                <span class="text-sm text-gray-600">Total de Hospedagens</span>
                <span class="text-sm font-semibold text-gray-900">{{ bookingCount }}</span>
              </div>
              <div class="flex justify-between items-center py-2 border-b border-gray-100">
                <span class="text-sm text-gray-600">Total de Faxinas</span>
                <span class="text-sm font-semibold text-gray-900">{{ cleaningCount }}</span>
              </div>
              <div class="flex justify-between items-center py-2 border-b border-gray-100">
                <span class="text-sm text-gray-600">Margem Média</span>
                <span class="text-sm font-semibold" :class="averageMargin >= 0 ? 'text-green-600' : 'text-red-600'">
                  {{ formatCurrency(averageMargin) }}
                </span>
              </div>
              <div class="flex justify-between items-center py-2">
                <span class="text-sm text-gray-600">Taxa de Recebimento</span>
                <span class="text-sm font-semibold text-indigo-600">
                  {{ receivedRate }}%
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { useApi } from '../composables/useApi.js'

export default {
  data() {
    const today = new Date()
    const firstDayOfMonth = new Date(today.getFullYear(), today.getMonth(), 1)
    const startDate = firstDayOfMonth.toISOString().split('T')[0]
    
    return {
      bookings: [],
      properties: [],
      loading: false,
      filterType: 'all',
      filters: {
        propertyId: '',
        startDate: startDate,
        endDate: ''
      }
    }
  },

  computed: {
    filteredBookings() {
      if (this.filterType === 'all') return this.bookings
      if (this.filterType === 'cleaning') {
        return this.bookings.filter(b => b.type === 'Service')
      }
      return this.bookings.filter(b => b.type !== 'Service')
    },

    totals() {
      const totalDue = this.bookings.reduce((sum, b) => sum + (parseFloat(b.total_due) || 0), 0)
      const totalReceived = this.bookings.reduce((sum, b) => sum + (parseFloat(b.deposit_amount) || 0) + (parseFloat(b.final_amount) || 0), 0)
      const balanceDue = totalDue - totalReceived
      
      const totalPayable = this.bookings.reduce((sum, b) => sum + (parseFloat(b.total_payable) || 0), 0)
      const totalPaid = this.bookings.reduce((sum, b) => sum + (parseFloat(b.total_paid) || 0), 0)
      const balancePayable = totalPayable - totalPaid

      return {
        totalDue,
        totalReceived,
        balanceDue,
        totalPayable,
        totalPaid,
        balancePayable
      }
    },

    balance() {
      return this.totals.totalDue - this.totals.totalPayable
    },

    bookingCount() {
      return this.bookings.filter(b => b.type !== 'Service').length
    },

    cleaningCount() {
      return this.bookings.filter(b => b.type === 'Service').length
    },

    averageMargin() {
      if (this.bookings.length === 0) return 0
      const totalMargin = this.bookings.reduce((sum, b) => sum + this.calculateMargin(b), 0)
      return totalMargin / this.bookings.length
    },

    receivedRate() {
      if (this.totals.totalDue === 0) return 0
      return ((this.totals.totalReceived / this.totals.totalDue) * 100).toFixed(1)
    }
  },

  mounted() {
    this.loadProperties()
    this.loadBookings()
  },

  methods: {
    async loadBookings() {
      if (!this.filters.startDate) {
        return
      }
      
      this.loading = true
      try {
        const { get } = useApi()
        const params = new URLSearchParams()
        
        if (this.filters.propertyId) {
          params.append('property_id', this.filters.propertyId)
        }
        if (this.filters.startDate) {
          params.append('start_date', this.filters.startDate)
        }
        if (this.filters.endDate) {
          params.append('end_date', this.filters.endDate)
        }
        
        const queryString = params.toString()
        const url = `/api/v1/stays${queryString ? '?' + queryString : ''}`
        
        const { data, error } = await get(url)
        if (!error) {
          this.bookings = data
        }
      } catch (err) {
        console.error('Error loading bookings:', err)
      } finally {
        this.loading = false
      }
    },

    async loadProperties() {
      try {
        const { getProperties } = useApi()
        const { data, error } = await getProperties()
        if (!error) {
          this.properties = data
        }
      } catch (err) {
        console.error('Error loading properties:', err)
      }
    },

    formatCurrency(value) {
      return new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL'
      }).format(value || 0)
    },

    formatDate(dateString) {
      if (!dateString) return '-'
      const date = new Date(dateString)
      return date.toLocaleDateString('pt-BR')
    },

    calculateMargin(booking) {
      const revenue = parseFloat(booking.total_due) || 0
      const cost = parseFloat(booking.total_payable) || 0
      return revenue - cost
    },

    getMarginColor(booking) {
      const margin = this.calculateMargin(booking)
      if (margin > 0) return 'text-green-600'
      if (margin < 0) return 'text-red-600'
      return 'text-gray-600'
    },

    getPercentage(value) {
      const total = this.totals.totalDue + this.totals.totalPayable
      if (total === 0) return 0
      return (value / total * 100).toFixed(1)
    }
  }
}
</script>
