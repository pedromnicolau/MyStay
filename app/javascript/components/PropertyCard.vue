<template>
  <div class="bg-white rounded-2xl overflow-hidden shadow-lg hover:shadow-2xl transition-shadow duration-300 cursor-pointer"
       @click="$emit('view-details')">
    <!-- Image Gallery Container -->
    <div class="relative w-full bg-gray-200 group">
      <!-- Main Image -->
      <div class="relative w-full pb-[66.66%] overflow-hidden bg-gray-300">
        <img 
          v-if="currentImage"
          :src="currentImage"
          :alt="property.name"
          class="absolute inset-0 w-full h-full object-cover transition-transform duration-300 group-hover:scale-105"
        />
        <div v-else class="absolute inset-0 flex items-center justify-center bg-gray-300">
          <span class="text-gray-400">Sem imagens</span>
        </div>
      </div>

      <!-- Image Counter Badge -->
      <div class="absolute top-3 right-3 bg-black bg-opacity-60 text-white px-2 py-1 rounded-full text-xs font-semibold">
        {{ currentImageIndex + 1 }} / {{ property.images.length }}
      </div>

      <!-- Previous Arrow -->
      <button 
        v-if="property.images.length > 1"
        @click.stop="previousImage"
        class="absolute left-2 top-1/2 transform -translate-y-1/2 bg-white bg-opacity-70 hover:bg-opacity-100 rounded-full p-2 transition-all duration-200 opacity-0 group-hover:opacity-100 z-10"
        aria-label="Imagem anterior"
      >
        <svg class="w-5 h-5 text-gray-900" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
        </svg>
      </button>

      <!-- Next Arrow -->
      <button 
        v-if="property.images.length > 1"
        @click.stop="nextImage"
        class="absolute right-2 top-1/2 transform -translate-y-1/2 bg-white bg-opacity-70 hover:bg-opacity-100 rounded-full p-2 transition-all duration-200 opacity-0 group-hover:opacity-100 z-10"
        aria-label="Próxima imagem"
      >
        <svg class="w-5 h-5 text-gray-900" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
        </svg>
      </button>

      <!-- Image Dots -->
      <div v-if="property.images.length > 1" class="absolute bottom-3 left-1/2 transform -translate-x-1/2 flex gap-1">
        <button 
          v-for="(_, index) in property.images"
          :key="index"
          @click.stop="goToImage(index)"
          :class="[
            'h-2 rounded-full transition-all duration-200',
            index === currentImageIndex 
              ? 'bg-white w-6' 
              : 'bg-white bg-opacity-50 w-2 hover:bg-opacity-75'
          ]"
          :aria-label="`Imagem ${index + 1}`"
        />
      </div>

      <!-- Favorite Button -->
      <button 
        @click.stop="toggleFavorite"
        class="absolute top-3 left-3 bg-white rounded-full p-2 transition-all duration-200 hover:scale-110"
        :aria-label="isFavorite ? 'Remover de favoritos' : 'Adicionar aos favoritos'"
      >
        <svg 
          :class="['w-5 h-5 transition-colors', isFavorite ? 'text-red-500 fill-current' : 'text-gray-400']"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
        </svg>
      </button>
    </div>

    <!-- Property Info -->
    <div class="p-4">
      <!-- Location and Rating -->
      <div class="flex justify-between items-start mb-2">
        <div class="flex-1">
          <h3 class="text-lg font-bold text-gray-900 line-clamp-2 mb-1">{{ property.name }}</h3>
          <p class="text-sm text-gray-600 flex items-center gap-1">
            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M5.05 4.05a7 7 0 119.9 9.9L10 18.9l-4.95-4.95a7 7 0 010-9.9zM10 11a2 2 0 100-4 2 2 0 000 4z" clip-rule="evenodd" />
            </svg>
            {{ property.neighborhood }}, {{ property.city }}
          </p>
        </div>
      </div>

      <!-- Description -->
      <p class="text-sm text-gray-600 mb-3 line-clamp-2">
        {{ property.description_short || 'Descrição não disponível' }}
      </p>

      <!-- Amenities Icons -->
      <div class="flex gap-2 mb-4 pb-4 border-b border-gray-200">
        <div v-if="property.bedrooms > 0" class="flex items-center gap-1 text-xs text-gray-600">
          <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
            <path d="M10.707 2.293a1 1 0 00-1.414 0l-7 7a1 1 0 001.414 1.414L4 10.414V17a1 1 0 001 1h2a1 1 0 001-1v-2a1 1 0 011-1h2a1 1 0 011 1v2a1 1 0 001 1h2a1 1 0 001-1v-6.586l.293.293a1 1 0 001.414-1.414l-7-7z" />
          </svg>
          <span>{{ property.bedrooms }}</span>
        </div>
        <div v-if="property.bathrooms > 0" class="flex items-center gap-1 text-xs text-gray-600">
          <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M4 4a2 2 0 00-2 2v4a1 1 0 001 1h12a1 1 0 001-1V6a2 2 0 00-2-2H4zm12 6H4v4a2 2 0 002 2h8a2 2 0 002-2v-4z" clip-rule="evenodd" />
          </svg>
          <span>{{ property.bathrooms }}</span>
        </div>
        <div v-if="property.max_guests > 0" class="flex items-center gap-1 text-xs text-gray-600">
          <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
            <path d="M9 6a3 3 0 11-6 0 3 3 0 016 0zM9 0a1 1 0 11-2 0 1 1 0 012 0zM16 6a3 3 0 11-6 0 3 3 0 016 0zM21 6a3 3 0 11-6 0 3 3 0 016 0z" />
          </svg>
          <span>{{ property.max_guests }}</span>
        </div>
      </div>

      <!-- CTA Button -->
      <button 
        @click.stop="$emit('view-details')"
        class="w-full bg-gradient-to-r from-indigo-600 to-indigo-700 text-white font-semibold py-2 rounded-lg hover:from-indigo-700 hover:to-indigo-800 transition-all duration-200 transform hover:scale-105"
      >
        Ver Detalhes
      </button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PropertyCard',
  props: {
    property: {
      type: Object,
      required: true,
      validator: (obj) => obj.id && obj.name && Array.isArray(obj.images)
    }
  },
  emits: ['view-details'],
  
  data() {
    return {
      currentImageIndex: 0,
      isFavorite: false
    }
  },

  computed: {
    currentImage() {
      return this.property.images?.[this.currentImageIndex]
    }
  },

  methods: {
    nextImage() {
      if (this.property.images.length > 1) {
        this.currentImageIndex = (this.currentImageIndex + 1) % this.property.images.length
      }
    },

    previousImage() {
      if (this.property.images.length > 1) {
        this.currentImageIndex = (this.currentImageIndex - 1 + this.property.images.length) % this.property.images.length
      }
    },

    goToImage(index) {
      if (index >= 0 && index < this.property.images.length) {
        this.currentImageIndex = index
      }
    },

    toggleFavorite() {
      this.isFavorite = !this.isFavorite
      // TODO: Implement favorite functionality with backend
    }
  }
}
</script>
