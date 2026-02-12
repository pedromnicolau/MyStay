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
          <div class="col-span-2 row-span-2 rounded-xl overflow-hidden bg-gray-300 relative group cursor-pointer"
               @click="openLightbox(currentImageIndex)">
            <img 
              v-if="currentImage"
              :src="currentImage"
              :alt="property.name"
              class="w-full h-full object-cover transition-transform duration-300 group-hover:scale-105"
            />
            
            <!-- Navigation arrows for main image -->
            <button 
              v-if="property.images.length > 1"
              @click.stop="previousImage"
              class="absolute left-2 top-1/2 transform -translate-y-1/2 bg-white bg-opacity-70 hover:bg-opacity-100 rounded-full p-3 transition-all duration-200 opacity-0 group-hover:opacity-100 z-10"
              aria-label="Imagem anterior"
            >
              <i class="fas fa-chevron-left text-gray-900 text-lg"></i>
            </button>

            <button 
              v-if="property.images.length > 1"
              @click.stop="nextImage"
              class="absolute right-2 top-1/2 transform -translate-y-1/2 bg-white bg-opacity-70 hover:bg-opacity-100 rounded-full p-3 transition-all duration-200 opacity-0 group-hover:opacity-100 z-10"
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
               @click="openLightbox(0)">
            <img v-if="property.images[0]" :src="property.images[0]" :alt="`${property.name} - imagem 1`" class="w-full h-full object-cover" />
          </div>

          <div v-if="property.images[1]" class="col-span-1 row-span-1 rounded-lg overflow-hidden bg-gray-300 cursor-pointer hover:opacity-80 transition-opacity"
               @click="openLightbox(1)">
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

          <!-- Location Map -->
          <div class="mb-8">
            <PropertyMap :property="property" />
          </div>
        </div>

        <!-- Right Column - Sidebar -->
        <div class="col-span-1">
          <!-- Contact/Booking Card -->
          <div class="bg-white rounded-2xl shadow-lg p-6 sticky top-24 border-2 border-indigo-100">
            <h3 class="text-2xl font-bold text-gray-900 mb-6">Interessado?</h3>
            
            <!-- Host Profile Section -->
            <div v-if="property.user && property.user.first_name" class="flex items-center gap-3 mb-6 p-3 bg-gradient-to-r from-indigo-50 to-purple-50 rounded-xl border border-indigo-100">
              <!-- Profile Image or Initials Avatar -->
              <div v-if="property.user.profile_image" class="flex-shrink-0">
                <img 
                  :src="property.user.profile_image" 
                  :alt="hostFullName"
                  class="w-14 h-14 rounded-full object-cover border-2 border-white shadow-md"
                />
              </div>
              <div v-else class="flex-shrink-0">
                <div class="w-14 h-14 rounded-full bg-gradient-to-br from-indigo-500 to-purple-600 flex items-center justify-center border-2 border-white shadow-md">
                  <span class="text-white font-bold text-lg">{{ hostInitials }}</span>
                </div>
              </div>
              
              <!-- Host Info -->
              <div class="flex-1 min-w-0">
                <p class="text-xs font-semibold text-indigo-600 uppercase tracking-wide mb-0.5">Anfitrião</p>
                <p class="text-gray-900 font-bold text-base truncate">{{ hostFullName }}</p>
              </div>
            </div>

            <p class="text-gray-600 mb-6 text-sm">
              Entre em contato conosco para agendar uma visita ou obter mais informações sobre este imóvel.
            </p>

            <button 
              v-if="property.user && property.user.phone"
              @click="redirectToWhatsApp"
              class="w-full bg-gradient-to-r from-green-500 to-green-600 text-white font-bold py-3 rounded-lg hover:from-green-600 hover:to-green-700 transition-all duration-200 transform hover:scale-105 mb-3 flex items-center justify-center gap-2"
            >
              <i class="fab fa-whatsapp text-lg"></i>
              Entrar em Contato
            </button>

            <button 
              @click="showCalendarModal = true"
              class="w-full bg-gray-100 text-gray-900 font-bold py-3 rounded-lg hover:bg-gray-200 transition-all duration-200 flex items-center justify-center gap-2"
            >
              <i class="fas fa-bed text-lg"></i>
              Agendar Estadia
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
        </div>
      </div>
    </div>

    <!-- Calendar Modal -->
    <div v-if="showCalendarModal" class="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center p-4"
         @click="showCalendarModal = false">
      <div class="bg-white rounded-xl shadow-xl max-w-md w-full p-6" @click.stop>
        <div class="flex justify-between items-center mb-6">
          <h3 class="text-2xl font-bold text-gray-900">Agendar Estadia</h3>
          <button @click="showCalendarModal = false" class="text-gray-400 hover:text-gray-600 text-2xl">
            ✕
          </button>
        </div>
        
        <div v-if="!property.user || !property.user.phone" class="bg-yellow-50 border border-yellow-200 rounded-lg p-4 mb-6">
          <p class="text-sm text-yellow-800">
            <i class="fas fa-info-circle mr-2"></i>
            Não há número de contato disponível para este imóvel.
          </p>
        </div>
        
        <PropertyCalendar 
          :unavailable-dates="property.unavailable_dates || []"
          @dates-selected="handleDateRangeSelected"
        />
      </div>
    </div>

    <!-- All Images Modal -->
    <div v-if="showAllImages" class="fixed inset-0 bg-black bg-opacity-75 z-50 flex items-center justify-center p-4"
         @click="showAllImages = false">
      <button @click="showAllImages = false" class="absolute top-4 right-4 text-white text-2xl font-bold hover:text-gray-300 z-10">
        ✕
      </button>
      
      <div class="max-w-4xl w-full" @click.stop>
        <h3 class="text-white text-2xl font-bold mb-4 text-center">Todas as Fotos</h3>
        <div class="grid grid-cols-2 gap-4 max-h-[80vh] overflow-y-auto">
          <img 
            v-for="(image, index) in property.images"
            :key="index"
            :src="image"
            :alt="`${property.name} - imagem ${index + 1}`"
            class="w-full h-64 object-cover rounded-lg cursor-pointer hover:opacity-80 transition-opacity hover:scale-105 transform duration-200"
            @click="openLightbox(index); showAllImages = false"
          />
        </div>
      </div>
    </div>

    <!-- Lightbox Modal -->
    <transition name="lightbox-fade">
      <div v-if="showLightbox" 
           class="fixed inset-0 bg-black bg-opacity-95 z-[60] flex items-center justify-center"
           @click="closeLightbox">
        
        <!-- Close Button -->
        <button 
          @click="closeLightbox"
          class="absolute top-4 right-4 z-[70] text-white hover:text-gray-300 transition-colors p-2 rounded-full hover:bg-white hover:bg-opacity-10"
          aria-label="Fechar"
        >
          <i class="fas fa-times text-3xl"></i>
        </button>

        <!-- Image Counter -->
        <div class="absolute top-4 left-1/2 transform -translate-x-1/2 z-[70] bg-black bg-opacity-60 text-white px-6 py-2 rounded-full text-lg font-semibold">
          {{ lightboxIndex + 1 }} / {{ property.images.length }}
        </div>

        <!-- Previous Button -->
        <button 
          v-if="property.images.length > 1"
          @click.stop="previousLightboxImage"
          class="absolute left-4 top-1/2 transform -translate-y-1/2 z-[70] bg-white bg-opacity-20 hover:bg-opacity-30 text-white rounded-full p-4 transition-all duration-200 backdrop-blur-sm"
          aria-label="Imagem anterior"
        >
          <i class="fas fa-chevron-left text-2xl"></i>
        </button>

        <!-- Next Button -->
        <button 
          v-if="property.images.length > 1"
          @click.stop="nextLightboxImage"
          class="absolute right-4 top-1/2 transform -translate-y-1/2 z-[70] bg-white bg-opacity-20 hover:bg-opacity-30 text-white rounded-full p-4 transition-all duration-200 backdrop-blur-sm"
          aria-label="Próxima imagem"
        >
          <i class="fas fa-chevron-right text-2xl"></i>
        </button>

        <!-- Main Image -->
        <div class="relative max-w-7xl max-h-[90vh] w-full h-full flex items-center justify-center p-4" @click.stop>
          <transition name="lightbox-slide" mode="out-in">
            <img 
              :key="lightboxIndex"
              :src="property.images[lightboxIndex]"
              :alt="`${property.name} - imagem ${lightboxIndex + 1}`"
              class="max-w-full max-h-full object-contain rounded-lg shadow-2xl"
              @click.stop
            />
          </transition>
        </div>

        <!-- Thumbnail Strip -->
        <div class="absolute bottom-4 left-1/2 transform -translate-x-1/2 z-[70] max-w-6xl w-full px-4">
          <div class="bg-black bg-opacity-60 backdrop-blur-sm rounded-lg p-3">
            <div class="flex gap-2 overflow-x-auto scrollbar-thin scrollbar-thumb-gray-600 scrollbar-track-transparent">
              <div 
                v-for="(image, index) in property.images"
                :key="index"
                @click.stop="lightboxIndex = index"
                :class="[
                  'flex-shrink-0 w-20 h-20 rounded-lg overflow-hidden cursor-pointer transition-all duration-200 border-2',
                  index === lightboxIndex 
                    ? 'border-white scale-105 ring-2 ring-white ring-offset-2 ring-offset-black' 
                    : 'border-transparent opacity-60 hover:opacity-100 hover:border-gray-400'
                ]"
              >
                <img 
                  :src="image"
                  :alt="`Thumbnail ${index + 1}`"
                  class="w-full h-full object-cover"
                />
              </div>
            </div>
          </div>
        </div>

        <!-- Download Button (Optional) -->
        <a 
          :href="property.images[lightboxIndex]"
          :download="`${property.name}-${lightboxIndex + 1}.jpg`"
          target="_blank"
          @click.stop
          class="absolute top-4 right-20 z-[70] bg-white bg-opacity-20 hover:bg-opacity-30 text-white rounded-full p-3 transition-all duration-200 backdrop-blur-sm"
          aria-label="Baixar imagem"
        >
          <i class="fas fa-download text-xl"></i>
        </a>
      </div>
    </transition>
  </div>
</template>

<script>
import { goBack } from '../router'
import PropertyCalendar from './PropertyCalendar.vue'
import PropertyMap from './PropertyMap.vue'

export default {
  name: 'PropertyDetail',
  components: {
    PropertyCalendar,
    PropertyMap
  },
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
      showAllImages: false,
      showCalendarModal: false,
      showLightbox: false,
      lightboxIndex: 0
    }
  },

  computed: {
    currentImage() {
      return this.property?.images?.[this.currentImageIndex]
    },

    hasAmenities() {
      if (!this.property?.amenities) return false
      return Object.values(this.property.amenities).some(v => v === true)
    },

    hostFullName() {
      if (!this.property || !this.property.user) return ''
      const first = this.property.user.first_name || ''
      const last = this.property.user.last_name || ''
      return `${first}${last ? ' ' + last : ''}`
    },

    hostInitials() {
      if (!this.property || !this.property.user) return ''
      const first = (this.property.user.first_name || '').charAt(0).toUpperCase()
      const last = (this.property.user.last_name || '').charAt(0).toUpperCase()
      return first + last || first || '?'
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
      const [year, month, day] = date.split(/[-T]/).slice(0, 3).map(Number)
      const d = new Date(year, month - 1, day)
      return d.toLocaleDateString('pt-BR', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric'
      })
    },

    redirectToWhatsApp() {
      if (!this.property.user || !this.property.user.phone) return
      
      // Remove non-digit characters from phone
      const phone = this.property.user.phone.replace(/\D/g, '')
      
      // If phone doesn't start with country code, add Brazil's +55
      const fullPhone = phone.length === 11 ? `55${phone}` : phone
      
      const message = `Olá, gostaria de obter mais informações sobre o imóvel: ${this.property.name}`
      const encodedMessage = encodeURIComponent(message)
      const whatsappUrl = `https://wa.me/${fullPhone}?text=${encodedMessage}`
      
      window.open(whatsappUrl, '_blank')
    },

    handleDateRangeSelected(dates) {
      this.showCalendarModal = false
      
      // Check if user has phone number
      if (!this.property.user || !this.property.user.phone) {
        alert('Não há número de contato disponível para este imóvel. Por favor, tente mais tarde.')
        return
      }
      
      // Format dates for display (using local timezone to avoid date shift)
      const [checkInYear, checkInMonth, checkInDay] = dates.checkIn.split('-').map(Number)
      const [checkOutYear, checkOutMonth, checkOutDay] = dates.checkOut.split('-').map(Number)
      
      const checkInDate = new Date(checkInYear, checkInMonth - 1, checkInDay)
      const checkOutDate = new Date(checkOutYear, checkOutMonth - 1, checkOutDay)
      
      const formattedCheckIn = checkInDate.toLocaleDateString('pt-BR', { weekday: 'short', day: 'numeric', month: 'short', year: 'numeric' })
      const formattedCheckOut = checkOutDate.toLocaleDateString('pt-BR', { weekday: 'short', day: 'numeric', month: 'short', year: 'numeric' })
      
      const phone = this.property.user.phone.replace(/\D/g, '')
      const fullPhone = phone.length === 11 ? `55${phone}` : phone
      
      const message = `Olá! Gostaria de agendar uma estadia no imóvel "${this.property.name}" de ${formattedCheckIn} até ${formattedCheckOut}. Qual seria o valor da diária?`
      const encodedMessage = encodeURIComponent(message)
      const whatsappUrl = `https://wa.me/${fullPhone}?text=${encodedMessage}`
      
      window.open(whatsappUrl, '_blank')
    },

    // Lightbox methods
    openLightbox(index) {
      this.lightboxIndex = index
      this.showLightbox = true
      document.body.style.overflow = 'hidden' // Prevent background scrolling
    },

    closeLightbox() {
      this.showLightbox = false
      document.body.style.overflow = '' // Restore scrolling
    },

    nextLightboxImage() {
      if (this.property?.images?.length > 1) {
        this.lightboxIndex = (this.lightboxIndex + 1) % this.property.images.length
      }
    },

    previousLightboxImage() {
      if (this.property?.images?.length > 1) {
        this.lightboxIndex = (this.lightboxIndex - 1 + this.property.images.length) % this.property.images.length
      }
    },

    handleKeydown(e) {
      if (!this.showLightbox) return
      
      if (e.key === 'Escape') {
        this.closeLightbox()
      } else if (e.key === 'ArrowRight') {
        this.nextLightboxImage()
      } else if (e.key === 'ArrowLeft') {
        this.previousLightboxImage()
      }
    }
  },

  mounted() {
    this.loadPropertyDetails()
    window.addEventListener('keydown', this.handleKeydown)
  },

  beforeUnmount() {
    window.removeEventListener('keydown', this.handleKeydown)
    document.body.style.overflow = '' // Ensure scrolling is restored
  }
}
</script>

<style scoped>
/* Lightbox Fade Transition */
.lightbox-fade-enter-active,
.lightbox-fade-leave-active {
  transition: opacity 0.3s ease;
}

.lightbox-fade-enter-from,
.lightbox-fade-leave-to {
  opacity: 0;
}

/* Lightbox Slide Transition */
.lightbox-slide-enter-active,
.lightbox-slide-leave-active {
  transition: all 0.3s ease;
}

.lightbox-slide-enter-from {
  opacity: 0;
  transform: translateX(30px);
}

.lightbox-slide-leave-to {
  opacity: 0;
  transform: translateX(-30px);
}

/* Custom Scrollbar for Thumbnail Strip */
.scrollbar-thin {
  scrollbar-width: thin;
}

.scrollbar-thin::-webkit-scrollbar {
  height: 6px;
}

.scrollbar-thin::-webkit-scrollbar-track {
  background: transparent;
}

.scrollbar-thin::-webkit-scrollbar-thumb {
  background: rgba(156, 163, 175, 0.5);
  border-radius: 3px;
}

.scrollbar-thin::-webkit-scrollbar-thumb:hover {
  background: rgba(156, 163, 175, 0.7);
}
</style>
