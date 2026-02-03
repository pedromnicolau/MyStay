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
    
    <div v-if="property.address && property.city" class="mt-4 p-4 bg-gray-50 rounded-lg">
      <p class="text-sm text-gray-700">
        <i class="fas fa-map-marker-alt text-indigo-600 mr-2"></i>
        <strong>Endereço:</strong> {{ fullAddress }}
      </p>
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
      coordinates: null,
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
      if (this.property.zip) parts.push(`CEP: ${this.property.zip}`)
      
      return parts.join(', ')
    },

    mapUrl() {
      if (!this.coordinates) return null
      
      const { lat, lon } = this.coordinates
      const zoom = 15
      
      // OpenStreetMap embed with marker
      return `https://www.openstreetmap.org/export/embed.html?bbox=${lon-0.01},${lat-0.01},${lon+0.01},${lat+0.01}&layer=mapnik&marker=${lat},${lon}`
    }
  },

  methods: {
    async fetchCoordinates() {
      // Try to get coordinates from CEP first
      if (this.property.zip) {
        this.loading = true
        try {
          const cep = this.property.zip.replace(/\D/g, '')
          const response = await fetch(`https://viacep.com.br/ws/${cep}/json/`)
          const data = await response.json()
          
          if (!data.erro) {
            // ViaCEP doesn't provide coordinates, so we'll use Nominatim
            const address = `${data.logradouro}, ${data.bairro}, ${data.localidade}, ${data.uf}, Brazil`
            await this.fetchCoordinatesFromAddress(address)
            return
          }
        } catch (error) {
          console.error('Error fetching CEP:', error)
        } finally {
          this.loading = false
        }
      }
      
      // Fallback to full address
      if (this.fullAddress) {
        await this.fetchCoordinatesFromAddress(this.fullAddress)
      }
    },

    async fetchCoordinatesFromAddress(address) {
      this.loading = true
      try {
        const encodedAddress = encodeURIComponent(address)
        const response = await fetch(
          `https://nominatim.openstreetmap.org/search?format=json&q=${encodedAddress}&limit=1`,
          {
            headers: {
              'User-Agent': 'MyStay Property Viewer'
            }
          }
        )
        const data = await response.json()
        
        if (data.length > 0) {
          this.coordinates = {
            lat: parseFloat(data[0].lat),
            lon: parseFloat(data[0].lon)
          }
        }
      } catch (error) {
        console.error('Error fetching coordinates:', error)
      } finally {
        this.loading = false
      }
    }
  },

  mounted() {
    this.fetchCoordinates()
  }
}
</script>
