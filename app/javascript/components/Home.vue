<template>
  <div class="min-h-screen bg-gray-50">
    <Navbar :user="user" />
    
    <Dashboard v-if="currentRoute === 'dashboard'" />
    <Customers v-else-if="currentRoute === 'customers'" />
    <Sellers v-else-if="currentRoute === 'sellers'" />
    <Cleaners v-else-if="currentRoute === 'cleaners'" />
    <Properties v-else-if="currentRoute === 'properties'" />
    <Bookings v-else-if="currentRoute === 'bookings'" />
    <Analysis v-else-if="currentRoute === 'analysis'" />
    <Profile v-else-if="currentRoute === 'profile'" :user="user" />
  </div>
</template>

<script>
import Navbar from './Navbar.vue'
import Dashboard from './Dashboard.vue'
import Customers from './Customers.vue'
import Sellers from './Sellers.vue'
import Cleaners from './Cleaners.vue'
import Properties from './Properties.vue'
import Bookings from './Bookings.vue'
import Analysis from './Analysis.vue'
import Profile from './Profile.vue'
import { router } from '../router.js'

export default {
  components: {
    Navbar,
    Dashboard,
    Customers,
    Sellers,
    Cleaners,
    Properties,
    Bookings,
    Analysis,
    Profile
  },

  props: {
    user: {
      type: Object,
      required: true
    }
  },

  computed: {
    currentRoute() {
      return router.currentRoute
    }
  }
}
</script>
