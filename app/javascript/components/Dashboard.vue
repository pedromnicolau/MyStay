<template>
  <div class="min-h-screen bg-gray-50">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <!-- Property Showcase for Tenant -->
      <PropertyShowcase :tenantMode="true" :showHeader="true" />
    </div>
  </div>
</template>

<script>
import axios from 'axios'
import { navigateTo } from '../router.js'
import PropertyShowcase from './PropertyShowcase.vue'

export default {
  components: {
    PropertyShowcase
  },
  
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
