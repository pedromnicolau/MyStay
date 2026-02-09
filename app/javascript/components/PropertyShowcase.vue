<template>
  <div class="w-full bg-gray-50 py-12" :class="{'mt-8': !tenantMode}">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <!-- Header Section -->
      <div v-if="showHeader" class="mb-12">
        <h4 class="text-4xl font-bold text-gray-900 mb-4">
          {{ tenantMode ? 'Analise seus imóveis' : 'Encontre Seu Próximo Destino' }}
        </h4>
        <p class="text-lg text-gray-600 mx-auto">
          {{ tenantMode
            ? 'Gerencie e visualize todos os seus imóveis cadastrados no sistema.'
            : 'Explore nossa seleção de imóveis incríveis disponíveis para aluguel de curto prazo. Escolha entre centenas de propriedades em localizações perfeitas.'
          }}
        </p>
      </div>

      <div v-if="tenantInfo && !tenantMode" class="mb-8 bg-indigo-50 border-l-4 border-indigo-600 p-6 rounded-lg">
        <div class="flex items-center">
          <svg class="w-6 h-6 text-indigo-600 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
          </svg>
          <div>
            <h3 class="text-lg font-semibold text-indigo-900">Imóveis de {{ tenantInfo.name }}</h3>
            <p class="text-sm text-indigo-700">Mostrando apenas os imóveis cadastrados por este proprietário</p>
          </div>
        </div>
      </div>

      <!-- Filters Section -->
      <div class="mb-8 bg-white rounded-xl shadow-md p-6">
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
          <!-- Search Filter -->
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">Buscar Imóvel</label>
            <div class="relative">
              <input 
                v-model="filters.search"
                type="text"
                placeholder="Nome, cidade, bairro..."
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-600 focus:border-transparent"
              />
              <svg class="absolute right-3 top-2.5 w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
            </div>
          </div>

          <!-- City Filter -->
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">Cidade</label>
            <select 
              v-model="filters.city"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-600 focus:border-transparent"
            >
              <option value="">Todas as cidades</option>
              <option v-for="city in cities" :key="city" :value="city">{{ city }}</option>
            </select>
          </div>

          <!-- Bedrooms Filter -->
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">Quartos</label>
            <select 
              v-model="filters.bedrooms"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-600 focus:border-transparent"
            >
              <option value="">Qualquer quantidade</option>
              <option value="1">1+ quartos</option>
              <option value="2">2+ quartos</option>
              <option value="3">3+ quartos</option>
              <option value="4">4+ quartos</option>
            </select>
          </div>

          <!-- Guests Filter -->
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">Hóspedes</label>
            <select 
              v-model="filters.guests"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-600 focus:border-transparent"
            >
              <option value="">Qualquer número</option>
              <option value="1">1+ hóspede</option>
              <option value="2">2+ hóspedes</option>
              <option value="4">4+ hóspedes</option>
              <option value="6">6+ hóspedes</option>
            </select>
          </div>
        </div>

        <!-- Amenities Filter -->
        <div class="mt-4 pt-4 border-t border-gray-200">
          <p class="text-sm font-semibold text-gray-700 mb-3">Comodidades</p>
          <div class="grid grid-cols-2 md:grid-cols-6 gap-3">
            <label class="flex items-center gap-2 cursor-pointer">
              <input v-model="filters.wifi" type="checkbox" class="rounded">
              <span class="text-sm text-gray-700">WiFi</span>
            </label>
            <label class="flex items-center gap-2 cursor-pointer">
              <input v-model="filters.air_conditioning" type="checkbox" class="rounded">
              <span class="text-sm text-gray-700">Ar Condicionado</span>
            </label>
            <label class="flex items-center gap-2 cursor-pointer">
              <input v-model="filters.pool" type="checkbox" class="rounded">
              <span class="text-sm text-gray-700">Piscina</span>
            </label>
            <label class="flex items-center gap-2 cursor-pointer">
              <input v-model="filters.parking" type="checkbox" class="rounded">
              <span class="text-sm text-gray-700">Estacionamento</span>
            </label>
            <label class="flex items-center gap-2 cursor-pointer">
              <input v-model="filters.pet_friendly" type="checkbox" class="rounded">
              <span class="text-sm text-gray-700">Pet Friendly</span>
            </label>
            <label class="flex items-center gap-2 cursor-pointer">
              <input v-model="filters.kitchen" type="checkbox" class="rounded">
              <span class="text-sm text-gray-700">Cozinha</span>
            </label>
          </div>
        </div>

        <!-- Filter Actions -->
        <div class="mt-4 flex gap-3">
          <button 
            @click="resetFilters"
            class="px-6 py-2 border border-gray-300 text-gray-700 font-semibold rounded-lg hover:bg-gray-50 transition-colors"
          >
            Limpar Filtros
          </button>
          <button 
            @click="applyFilters"
            class="px-6 py-2 bg-gradient-to-r from-indigo-600 to-indigo-700 text-white font-semibold rounded-lg hover:from-indigo-700 hover:to-indigo-800 transition-all"
          >
            Buscar
          </button>
        </div>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div v-for="i in 6" :key="i" class="bg-white rounded-2xl overflow-hidden shadow-lg animate-pulse">
          <div class="w-full bg-gray-300 pb-[66.66%]"></div>
          <div class="p-4 space-y-3">
            <div class="h-4 bg-gray-200 rounded w-2/3"></div>
            <div class="h-3 bg-gray-200 rounded w-1/2"></div>
            <div class="h-8 bg-gray-200 rounded"></div>
          </div>
        </div>
      </div>

      <!-- No Results -->
      <div v-else-if="filteredProperties.length === 0" class="text-center py-12">
        <svg class="mx-auto h-12 w-12 text-gray-400 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 21l-4.35-4.35M11 19a8 8 0 100-16 8 8 0 000 16z" />
        </svg>
        <h3 class="text-lg font-semibold text-gray-900 mb-2">Nenhum imóvel encontrado</h3>
        <p class="text-gray-600 mb-6">Tente ajustar seus filtros ou tente uma nova busca</p>
        <button 
          @click="resetFilters"
          class="px-6 py-2 bg-indigo-600 text-white font-semibold rounded-lg hover:bg-indigo-700 transition-colors"
        >
          Ver Todos os Imóveis
        </button>
      </div>

      <!-- Properties Grid -->
      <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <PropertyCard 
          v-for="property in filteredProperties"
          :key="property.id"
          :property="property"
          @view-details="viewPropertyDetails(property)"
        />
      </div>

      <!-- Load More Button -->
      <div v-if="hasMoreProperties" class="mt-12 text-center">
        <button 
          @click="loadMore"
          class="px-8 py-3 border-2 border-indigo-600 text-indigo-600 font-bold rounded-lg hover:bg-indigo-50 transition-colors"
        >
          Carregar Mais
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import PropertyCard from './PropertyCard.vue'
import { navigateTo } from '../router'
import axios from 'axios'

export default {
  name: 'PropertyShowcase',
  components: { PropertyCard },
  props: {
    tenantMode: {
      type: Boolean,
      default: false
    },
    showHeader: {
      type: Boolean,
      default: false
    }
  },

  data() {
    return {
      properties: [],
      loading: false,
      tenantInfo: null,
      tenantCode: null,
      filters: {
        search: '',
        city: '',
        bedrooms: '',
        guests: '',
        wifi: false,
        air_conditioning: false,
        pool: false,
        parking: false,
        pet_friendly: false,
        kitchen: false
      },
      displayCount: 12,
      allCities: new Set()
    }
  },

  computed: {
    cities() {
      return Array.from(this.allCities).sort()
    },

    filteredProperties() {
      let filtered = this.properties

      // Search filter
      if (this.filters.search) {
        const search = this.filters.search.toLowerCase()
        filtered = filtered.filter(p =>
          p.name.toLowerCase().includes(search) ||
          p.city.toLowerCase().includes(search) ||
          p.neighborhood.toLowerCase().includes(search)
        )
      }

      // City filter
      if (this.filters.city) {
        filtered = filtered.filter(p => p.city === this.filters.city)
      }

      // Bedrooms filter
      if (this.filters.bedrooms) {
        const minBedrooms = parseInt(this.filters.bedrooms)
        filtered = filtered.filter(p => p.bedrooms >= minBedrooms)
      }

      // Guests filter
      if (this.filters.guests) {
        const minGuests = parseInt(this.filters.guests)
        filtered = filtered.filter(p => p.max_guests >= minGuests)
      }

      // Amenities filters
      if (this.filters.wifi) {
        filtered = filtered.filter(p => p.amenities?.wifi)
      }
      if (this.filters.air_conditioning) {
        filtered = filtered.filter(p => p.amenities?.air_conditioning)
      }
      if (this.filters.pool) {
        filtered = filtered.filter(p => p.amenities?.pool)
      }
      if (this.filters.parking) {
        filtered = filtered.filter(p => p.amenities?.parking_included)
      }
      if (this.filters.pet_friendly) {
        filtered = filtered.filter(p => p.amenities?.pet_friendly)
      }
      if (this.filters.kitchen) {
        filtered = filtered.filter(p => p.amenities?.kitchen)
      }

      return filtered.slice(0, this.displayCount)
    },

    hasMoreProperties() {
      return this.filteredProperties.length < this.allFilteredProperties().length
    }
  },

  methods: {
    async loadProperties() {
      try {
        this.loading = true
        let data
        let tenantInfo = null

        if (this.tenantMode) {
          const userToken = localStorage.getItem('userToken')
          const tenantToken = localStorage.getItem('tenantToken')
          const response = await axios.get('/api/v1/properties', {
            headers: {
              'Authorization': `Bearer ${userToken}`,
              'Tenant-Authorization': `Bearer ${tenantToken}`
            }
          })
          // Backend now returns { data: [...], pagy: {...} }
          data = response.data.data || []
        } else {
          const url = this.tenantCode 
            ? `/api/v1/properties/public/showcase?tenant_code=${this.tenantCode}`
            : '/api/v1/properties/public/showcase'
          
          const response = await fetch(url)
          
          if (!response.ok) {
            throw new Error('Erro ao carregar imóveis')
          }
          const result = await response.json()
          
          if (result.properties) {
            data = result.properties
            tenantInfo = result.tenant
          } else {
            data = result
          }
        }

        this.properties = data
        this.tenantInfo = tenantInfo
        
        this.properties.forEach(p => {
          if (p.city) {
            this.allCities.add(p.city)
          }
        })
      } catch (err) {
        console.error('Error loading properties:', err)
      } finally {
        this.loading = false
      }
    },

    allFilteredProperties() {
      let filtered = this.properties

      if (this.filters.search) {
        const search = this.filters.search.toLowerCase()
        filtered = filtered.filter(p =>
          p.name.toLowerCase().includes(search) ||
          p.city.toLowerCase().includes(search) ||
          p.neighborhood.toLowerCase().includes(search)
        )
      }

      if (this.filters.city) {
        filtered = filtered.filter(p => p.city === this.filters.city)
      }

      if (this.filters.bedrooms) {
        const minBedrooms = parseInt(this.filters.bedrooms)
        filtered = filtered.filter(p => p.bedrooms >= minBedrooms)
      }

      if (this.filters.guests) {
        const minGuests = parseInt(this.filters.guests)
        filtered = filtered.filter(p => p.max_guests >= minGuests)
      }

      if (this.filters.wifi) {
        filtered = filtered.filter(p => p.amenities?.wifi)
      }
      if (this.filters.air_conditioning) {
        filtered = filtered.filter(p => p.amenities?.air_conditioning)
      }
      if (this.filters.pool) {
        filtered = filtered.filter(p => p.amenities?.pool)
      }
      if (this.filters.parking) {
        filtered = filtered.filter(p => p.amenities?.parking_included)
      }
      if (this.filters.pet_friendly) {
        filtered = filtered.filter(p => p.amenities?.pet_friendly)
      }
      if (this.filters.kitchen) {
        filtered = filtered.filter(p => p.amenities?.kitchen)
      }

      return filtered
    },

    applyFilters() {
      this.displayCount = 12
    },

    resetFilters() {
      this.filters = {
        search: '',
        city: '',
        bedrooms: '',
        guests: '',
        wifi: false,
        air_conditioning: false,
        pool: false,
        parking: false,
        pet_friendly: false,
        kitchen: false
      }
      this.displayCount = 12
    },

    loadMore() {
      this.displayCount += 12
    },

    viewPropertyDetails(property) {
      navigateTo('property-detail', { id: property.id })
    }
  },

  mounted() {
    if (!this.tenantMode) {
      const path = window.location.pathname
      const match = path.match(/^\/([a-zA-Z0-9_-]+)$/)
      if (match) {
        this.tenantCode = match[1]
      }
    }
    this.loadProperties()
  }
}
</script>
