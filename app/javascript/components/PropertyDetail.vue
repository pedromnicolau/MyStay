<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header/Navigation -->
    <nav class="bg-white border-b border-gray-200 sticky top-0 z-40">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center h-16">
          <button @click="goBackToLanding" class="flex items-center gap-2 hover:opacity-80 transition-opacity">
            <i class="fas fa-arrow-left text-gray-700 text-lg"></i>
            <span class="text-gray-700 font-semibold">Voltar</span>
          </button>
          <div class="flex items-center gap-3">
            <button @click="toggleFavorite" class="p-2 hover:bg-gray-100 rounded-full transition-colors">
              <i 
                :class="['fas fa-heart text-lg transition-colors', isFavorite ? 'text-red-500' : 'text-gray-400']"
              ></i>
            </button>
            <button @click="shareProperty" class="p-2 hover:bg-gray-100 rounded-full transition-colors">
              <i class="fas fa-share-alt text-lg text-gray-600"></i>
            </button>
          </div>
        </div>
      </div>
    </nav>

    <!-- Loading State -->
    <div v-if="loading" class="flex items-center justify-center min-h-[60vh]">
      <div class="text-center">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600 mx-auto mb-4"></div>
        <p class="text-gray-600">Carregando detalhes do imóvel...</p>
      </div>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="max-w-7xl mx-auto px-4 py-12">
      <div class="bg-red-50 border border-red-200 rounded-lg p-6 text-center">
        <p class="text-red-700 font-semibold">{{ error }}</p>
        <button @click="goBackToLanding" class="mt-4 text-indigo-600 hover:text-indigo-700 font-semibold">
          Voltar aos imóveis
        </button>
      </div>
    </div>

    <!-- Property Details -->
    <div v-else-if="property" class="max-w-7xl mx-auto px-4 py-8">
      <!-- Image Gallery Section -->
      <div class="mb-8">
        <div class="grid grid-cols-3 gap-2 mb-4 auto-rows-[250px]">
          <!-- Main large image -->
          <div class="col-span-2 row-span-2 rounded-xl overflow-hidden bg-gray-300 relative group">
            <img 
              v-if="currentImage"
              :src="currentImage"
              :alt="property.name"
              class="w-full h-full object-cover transition-transform duration-300 group-hover:scale-105"
            />
            
            <!-- Navigation arrows for main image -->
            <button 
              v-if="property.images.length > 1"
              @click="previousImage"
              class="absolute left-2 top-1/2 transform -translate-y-1/2 bg-white bg-opacity-70 hover:bg-opacity-100 rounded-full p-3 transition-all duration-200 opacity-0 group-hover:opacity-100"
              aria-label="Imagem anterior"
            >
              <i class="fas fa-chevron-left text-gray-900 text-lg"></i>
            </button>

            <button 
              v-if="property.images.length > 1"
              @click="nextImage"
              class="absolute right-2 top-1/2 transform -translate-y-1/2 bg-white bg-opacity-70 hover:bg-opacity-100 rounded-full p-3 transition-all duration-200 opacity-0 group-hover:opacity-100"
              aria-label="Próxima imagem"
            >
              <i class="fas fa-chevron-right text-gray-900 text-lg"></i>
            </button>

            <!-- Image counter -->
            <div class="absolute bottom-3 right-3 bg-black bg-opacity-60 text-white px-3 py-1 rounded-full text-sm font-semibold">
              {{ currentImageIndex + 1 }} / {{ property.images.length }}
            </div>
          </div>

          <!-- Thumbnail images -->
          <div class="col-span-1 row-span-1 rounded-lg overflow-hidden bg-gray-300 cursor-pointer hover:opacity-80 transition-opacity"
               @click="currentImageIndex = 0">
            <img v-if="property.images[0]" :src="property.images[0]" :alt="`${property.name} - imagem 1`" class="w-full h-full object-cover" />
          </div>

          <div v-if="property.images[1]" class="col-span-1 row-span-1 rounded-lg overflow-hidden bg-gray-300 cursor-pointer hover:opacity-80 transition-opacity"
               @click="currentImageIndex = 1">
            <img :src="property.images[1]" :alt="`${property.name} - imagem 2`" class="w-full h-full object-cover" />
          </div>

          <div v-if="property.images.length > 2" class="col-span-1 row-span-1 rounded-lg overflow-hidden bg-gray-300 cursor-pointer hover:opacity-80 transition-opacity relative"
               @click="showAllImages = true">
            <img :src="property.images[2]" :alt="`${property.name} - imagem 3`" class="w-full h-full object-cover" />
            <div class="absolute inset-0 bg-black bg-opacity-40 flex items-center justify-center">
              <span class="text-white font-bold text-lg">+{{ property.images.length - 2 }}</span>
            </div>
          </div>
        </div>

        <!-- Image dots navigator -->
        <div class="flex gap-1 justify-center flex-wrap">
          <button 
            v-for="(_, index) in property.images"
            :key="index"
            @click="currentImageIndex = index"
            :class="[
              'h-2 rounded-full transition-all duration-200',
              index === currentImageIndex 
                ? 'bg-indigo-600 w-8' 
                : 'bg-gray-300 w-2 hover:bg-gray-400'
            ]"
            :aria-label="`Imagem ${index + 1}`"
          />
        </div>
      </div>

      <!-- Main Content -->
      <div class="grid grid-cols-3 gap-8">
        <!-- Left Column - Property Info -->
        <div class="col-span-2">
          <!-- Header -->
          <div class="mb-8">
            <h1 class="text-4xl font-bold text-gray-900 mb-2">{{ property.name }}</h1>
            <div class="flex items-center gap-4 text-gray-600">
              <p class="flex items-center gap-2">
                <i class="fas fa-map-marker-alt text-indigo-600"></i>
                {{ property.address }}, {{ property.number }} - {{ property.neighborhood }}
              </p>
            </div>
            <p class="text-lg text-gray-500">{{ property.zip }} - {{ property.city }}, {{ property.state }}</p>
          </div>

          <!-- Quick Info Cards -->
          <div class="grid grid-cols-4 gap-4 mb-8">
            <div class="bg-gradient-to-br from-blue-50 to-blue-100 p-4 rounded-lg border border-blue-200">
              <div class="flex items-center gap-2 mb-2">
                <i class="fas fa-bed text-blue-600 text-2xl"></i>
                <span class="text-2xl font-bold text-blue-600">{{ property.bedrooms }}</span>
              </div>
              <p class="text-sm text-gray-700 font-semibold">{{ property.bedrooms === 1 ? 'Quarto' : 'Quartos' }}</p>
            </div>

            <div class="bg-gradient-to-br from-purple-50 to-purple-100 p-4 rounded-lg border border-purple-200">
              <div class="flex items-center gap-2 mb-2">
                <i class="fas fa-bath text-purple-600 text-2xl"></i>
                <span class="text-2xl font-bold text-purple-600">{{ property.bathrooms }}</span>
              </div>
              <p class="text-sm text-gray-700 font-semibold">{{ property.bathrooms === 1 ? 'Banheiro' : 'Banheiros' }}</p>
            </div>

            <div class="bg-gradient-to-br from-green-50 to-green-100 p-4 rounded-lg border border-green-200">
              <div class="flex items-center gap-2 mb-2">
                <i class="fas fa-users text-green-600 text-2xl"></i>
                <span class="text-2xl font-bold text-green-600">{{ property.max_guests }}</span>
              </div>
              <p class="text-sm text-gray-700 font-semibold">{{ property.max_guests === 1 ? 'Hóspede' : 'Hóspedes' }}</p>
            </div>

            <div class="bg-gradient-to-br from-orange-50 to-orange-100 p-4 rounded-lg border border-orange-200">
              <div class="flex items-center gap-2 mb-2">
                <i class="fas fa-info-circle text-orange-600 text-2xl"></i>
                <span class="text-sm text-orange-600 font-semibold">Info</span>
              </div>
              <p class="text-xs text-gray-700">Acesse para mais</p>
            </div>
          </div>

          <!-- Description -->
          <div class="mb-8">
            <h2 class="text-2xl font-bold text-gray-900 mb-4">Sobre o imóvel</h2>
            <p class="text-gray-700 text-lg leading-relaxed whitespace-pre-wrap">{{ property.description || 'Descrição não disponível' }}</p>
          </div>

          <!-- Amenities -->
          <div class="mb-8">
            <h2 class="text-2xl font-bold text-gray-900 mb-6">Comodidades</h2>
            <div class="grid grid-cols-2 gap-4">
              <div v-if="property.amenities.air_conditioning" class="flex items-center gap-3 p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
                <i class="fas fa-fan text-indigo-600 text-lg"></i>
                <span class="font-semibold text-gray-700">Ar Condicionado</span>
              </div>

              <div v-if="property.amenities.wifi" class="flex items-center gap-3 p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
                <i class="fas fa-wifi text-indigo-600 text-lg"></i>
                <span class="font-semibold text-gray-700">WiFi</span>
              </div>

              <div v-if="property.amenities.tv" class="flex items-center gap-3 p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
                <i class="fas fa-tv text-indigo-600 text-lg"></i>
                <span class="font-semibold text-gray-700">TV</span>
              </div>

              <div v-if="property.amenities.kitchen" class="flex items-center gap-3 p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
                <i class="fas fa-utensils text-indigo-600 text-lg"></i>
                <span class="font-semibold text-gray-700">Cozinha</span>
              </div>

              <div v-if="property.amenities.parking_included" class="flex items-center gap-3 p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
                <i class="fas fa-parking text-indigo-600 text-lg"></i>
                <span class="font-semibold text-gray-700">Estacionamento</span>
              </div>

              <div v-if="property.amenities.washing_machine" class="flex items-center gap-3 p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
                <i class="fas fa-washing-machine text-indigo-600 text-lg"></i>
                <span class="font-semibold text-gray-700">Máquina de Lavar</span>
              </div>

              <div v-if="property.amenities.pool" class="flex items-center gap-3 p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
                <i class="fas fa-water text-indigo-600 text-lg"></i>
                <span class="font-semibold text-gray-700">Piscina</span>
              </div>

              <div v-if="property.amenities.barbecue_grill" class="flex items-center gap-3 p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
                <i class="fas fa-fire text-indigo-600 text-lg"></i>
                <span class="font-semibold text-gray-700">Churrasqueira</span>
              </div>

              <div v-if="property.amenities.balcony" class="flex items-center gap-3 p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
                <i class="fas fa-door-open text-indigo-600 text-lg"></i>
                <span class="font-semibold text-gray-700">Varanda</span>
              </div>

              <div v-if="property.amenities.pet_friendly" class="flex items-center gap-3 p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
                <i class="fas fa-paw text-indigo-600 text-lg"></i>
                <span class="font-semibold text-gray-700">Pet Friendly</span>
              </div>

              <div v-if="property.amenities.wheelchair_accessible" class="flex items-center gap-3 p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
                <i class="fas fa-wheelchair text-indigo-600 text-lg"></i>
                <span class="font-semibold text-gray-700">Acessível</span>
              </div>
            </div>

            <div v-if="!hasAmenities" class="text-center py-8 text-gray-500">
              <p>Nenhuma comodidade selecionada</p>
            </div>
          </div>
        </div>

        <!-- Right Column - Sidebar -->
        <div class="col-span-1">
          <!-- Contact/Booking Card -->
          <div class="bg-white rounded-2xl shadow-lg p-6 sticky top-24 border-2 border-indigo-100">
            <h3 class="text-2xl font-bold text-gray-900 mb-6">Interessado?</h3>
            
            <p class="text-gray-600 mb-6 text-sm">
              Entre em contato conosco para agendar uma visita ou obter mais informações sobre este imóvel.
            </p>

            <button class="w-full bg-gradient-to-r from-indigo-600 to-indigo-700 text-white font-bold py-3 rounded-lg hover:from-indigo-700 hover:to-indigo-800 transition-all duration-200 transform hover:scale-105 mb-3">
              Solicitar Informações
            </button>

            <button class="w-full bg-gray-100 text-gray-900 font-bold py-3 rounded-lg hover:bg-gray-200 transition-all duration-200">
              Agendar Visita
            </button>

            <!-- Info Box -->
            <div class="mt-6 pt-6 border-t border-gray-200">
              <div class="space-y-4">
                <div class="flex items-start gap-3">
                  <i class="fas fa-calendar text-indigo-600 mt-1 flex-shrink-0"></i>
                  <div>
                    <p class="text-xs font-semibold text-gray-500 uppercase">Cadastro</p>
                    <p class="text-sm text-gray-700">{{ formatDate(property.created_at) }}</p>
                  </div>
                </div>

                <div class="flex items-start gap-3">
                  <i class="fas fa-map-marker-alt text-indigo-600 mt-1 flex-shrink-0"></i>
                  <div>
                    <p class="text-xs font-semibold text-gray-500 uppercase">Localização</p>
                    <p class="text-sm text-gray-700">{{ property.city }}, {{ property.state }}</p>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Share Card -->
          <div class="mt-6 bg-white rounded-xl shadow p-4 text-center">
            <p class="text-sm text-gray-600 mb-3 font-semibold">Compartilhe este imóvel</p>
            <div class="flex gap-2 justify-center">
              <button class="p-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors" aria-label="Facebook">
                <i class="fab fa-facebook-f text-lg"></i>
              </button>
              <button class="p-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors" aria-label="WhatsApp">
                <i class="fab fa-whatsapp text-lg"></i>
              </button>
              <button class="p-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors" aria-label="Email">
                <i class="fas fa-envelope text-lg"></i>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- All Images Modal -->
    <div v-if="showAllImages" class="fixed inset-0 bg-black bg-opacity-75 z-50 flex items-center justify-center p-4"
         @click="showAllImages = false">
      <button @click="showAllImages = false" class="absolute top-4 right-4 text-white text-2xl font-bold hover:text-gray-300">
        ✕
      </button>
      
      <div class="max-w-4xl w-full" @click.stop>
        <div class="grid grid-cols-2 gap-4 max-h-[80vh] overflow-y-auto">
          <img 
            v-for="(image, index) in property.images"
            :key="index"
            :src="image"
            :alt="`${property.name} - imagem ${index + 1}`"
            class="w-full h-64 object-cover rounded-lg cursor-pointer hover:opacity-80 transition-opacity"
            @click="currentImageIndex = index; showAllImages = false"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { goBack } from '../router'

export default {
  name: 'PropertyDetail',
  props: {
    propertyId: {
      type: [String, Number],
      required: true
    }
  },

  data() {
    return {
      property: null,
      loading: true,
      error: null,
      currentImageIndex: 0,
      isFavorite: false,
      showAllImages: false
    }
  },

  computed: {
    currentImage() {
      return this.property?.images?.[this.currentImageIndex]
    },

    hasAmenities() {
      if (!this.property?.amenities) return false
      return Object.values(this.property.amenities).some(v => v === true)
    }
  },

  methods: {
    async loadPropertyDetails() {
      try {
        this.loading = true
        this.error = null

        const response = await fetch(`/api/v1/properties/public/${this.propertyId}`)
        
        if (!response.ok) {
          throw new Error('Imóvel não encontrado')
        }

        this.property = await response.json()
      } catch (err) {
        this.error = err.message || 'Erro ao carregar detalhes do imóvel'
        console.error('Error loading property:', err)
      } finally {
        this.loading = false
      }
    },

    nextImage() {
      if (this.property?.images?.length > 1) {
        this.currentImageIndex = (this.currentImageIndex + 1) % this.property.images.length
      }
    },

    previousImage() {
      if (this.property?.images?.length > 1) {
        this.currentImageIndex = (this.currentImageIndex - 1 + this.property.images.length) % this.property.images.length
      }
    },

    toggleFavorite() {
      this.isFavorite = !this.isFavorite
      // TODO: Implement favorite functionality
    },

    shareProperty() {
      if (navigator.share) {
        navigator.share({
          title: this.property.name,
          text: `Confira este imóvel: ${this.property.name}`,
          url: window.location.href
        })
      }
    },

    goBackToLanding() {
      this.$emit('back')
    },

    formatDate(date) {
      if (!date) return ''
      return new Date(date).toLocaleDateString('pt-BR', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric'
      })
    }
  },

  mounted() {
    this.loadPropertyDetails()
  }
}
</script>
