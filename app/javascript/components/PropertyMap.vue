<template>
  <div class="w-full">
    <h2 class="text-2xl font-bold text-gray-900 mb-4">Localização</h2>
    <div class="relative w-full rounded-xl overflow-hidden shadow-lg border border-gray-200" style="height: 400px;">
      <div v-if="loading" class="w-full h-full bg-gray-100 flex items-center justify-center">
        <div class="text-center">
          <div class="animate-spin rounded-full h-10 w-10 border-b-2 border-indigo-600 mx-auto mb-3"></div>
          <p class="text-gray-500">Carregando mapa...</p>
        </div>
      </div>
      <iframe
        v-else-if="mapUrl"
        :src="mapUrl"
        width="100%"
        height="100%"
        style="border:0;"
        allowfullscreen=""
        loading="lazy"
        referrerpolicy="no-referrer-when-downgrade"
        class="w-full h-full"
      ></iframe>
      <div v-else class="w-full h-full bg-gray-100 flex items-center justify-center">
        <div class="text-center">
          <i class="fas fa-map-marked-alt text-gray-400 text-4xl mb-3"></i>
          <p class="text-gray-500">Localização não disponível</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PropertyMap',
  
  props: {
    property: {
      type: Object,
      required: true
    }
  },

  data() {
    return {
      loading: false
    }
  },

  computed: {
    fullAddress() {
      const parts = []
      
      if (this.property.address) parts.push(this.property.address)
      if (this.property.number) parts.push(this.property.number)
      if (this.property.neighborhood) parts.push(this.property.neighborhood)
      if (this.property.city) parts.push(this.property.city)
      if (this.property.state) parts.push(this.property.state)
      
      return parts.join(', ')
    },

    // Using Google Maps Embed API (free, no API key required for basic embedding)
    mapUrl() {
      // Build the address query for Google Maps
      let query = ''
      
      // Prioritize CEP (postal code) as it's the most accurate
      if (this.property.zip) {
        const cep = this.property.zip.replace(/\D/g, '')
        query = cep + ', Brasil'
      } else {
        // Fallback to full address
        query = this.fullAddress + ', Brasil'
      }
      
      if (!query) return null
      
      // Encode the query for URL
      const encodedQuery = encodeURIComponent(query)
      
      // Google Maps Embed URL (basic embed - no API key needed, but has limitations)
      // For production, get a free API key at: https://developers.google.com/maps/documentation/embed/get-api-key
      // Then replace 'YOUR_API_KEY' below with your actual key
      const apiKey = 'YOUR_API_KEY' // Replace with your Google Maps API key
      
      if (apiKey && apiKey !== 'YOUR_API_KEY') {
        // Using Embed API with API key (recommended)
        return `https://www.google.com/maps/embed/v1/place?key=${apiKey}&q=${encodedQuery}&zoom=15&maptype=roadmap`
      } else {
        // Using basic Google Maps iframe embed (free, no API key needed)
        // This method shows the location without needing an API key
        return `https://maps.google.com/maps?q=${encodedQuery}&t=&z=15&ie=UTF8&iwloc=&output=embed`
      }
    }
  },

  methods: {
    // No need for coordinate fetching since Google Maps handles it
  },

  mounted() {
    // Google Maps will handle the geocoding
  }
}
</script>
