<template>
  <div class="min-h-screen bg-gray-50">
    <Navbar :user="user" />
    
    <div class="pt-16">
      <Dashboard v-if="currentRoute === 'dashboard'" />
      <People v-else-if="currentRoute === 'people'" />
      <Properties v-else-if="currentRoute === 'properties'" />
      <Bookings v-else-if="currentRoute === 'bookings'" />
      <Analysis v-else-if="currentRoute === 'analysis'" />
      <Profile v-else-if="currentRoute === 'profile'" :user="user" @user-updated="handleUserUpdated" />
      <TenantSettings v-else-if="currentRoute === 'tenant-settings'" />
      <Users v-else-if="currentRoute === 'users'" />
      <ServiceTypes v-else-if="currentRoute === 'service-types'" />
      <PropertyDetail 
        v-else-if="currentRoute === 'property-detail'" 
        :propertyId="router.params.id" 
        @back="backToDashboard" 
      />
    </div>
  </div>
</template>

<script>
import Navbar from './Navbar.vue'
import Dashboard from './Dashboard.vue'
import People from './People.vue'
import Properties from './Properties.vue'
import Bookings from './Bookings.vue'
import Analysis from './Analysis.vue'
import Profile from './Profile.vue'
import TenantSettings from './TenantSettings.vue'
import Users from './Users.vue'
import ServiceTypes from './ServiceTypes.vue'
import PropertyDetail from './PropertyDetail.vue'
import { router, navigateTo } from '../router.js'

export default {
  components: {
    Navbar,
    Dashboard,
    People,
    Properties,
    Bookings,
    Analysis,
    Profile,
    TenantSettings,
    Users,
    ServiceTypes,
    PropertyDetail
  },
  emits: ['user-updated'],
  props: {
    user: {
      type: Object,
      required: true
    }
  },

  data() {
    return {
      router
    }
  },

  computed: {
    currentRoute() {
      return router.currentRoute
    }
  },

  methods: {
    backToDashboard() {
      navigateTo('dashboard')
    },
    handleUserUpdated(user) {
      this.$emit('user-updated', user)
    }
  }
}
</script>
