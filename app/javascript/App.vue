<template>
  <div id="app">
    <Landing v-if="!isLoggedIn && router.currentRoute === 'dashboard'" @auth-success="handleAuthSuccess" />
    <PropertyDetail v-else-if="!isLoggedIn && router.currentRoute === 'property-detail'" :propertyId="router.params.id" @back="backToLanding" />
    <Home v-else :user="currentUser" @user-updated="updateCurrentUser" />
  </div>
</template>

<script>
import Home from './components/Home.vue'
import Landing from './components/Landing.vue'
import PropertyDetail from './components/PropertyDetail.vue'
import { router, navigateTo } from './router'

export default {
  components: {
    Home,
    Landing,
    PropertyDetail
  },

  data() {
    return {
      isLoggedIn: false,
      currentUser: null,
      router: router
    }
  },

  mounted() {
    const userToken = localStorage.getItem('userToken')
    const user = localStorage.getItem('user')
    if (userToken && user) {
      this.currentUser = JSON.parse(user)
      this.isLoggedIn = true
    }
  },

  methods: {
    handleAuthSuccess(data) {
      this.currentUser = data.user
      this.isLoggedIn = true
    },

    updateCurrentUser(user) {
      this.currentUser = user
      if (user) {
        localStorage.setItem('user', JSON.stringify(user))
      }
    },

    backToLanding() {
      navigateTo('dashboard', {})
    }
  }
}
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
  background-color: #f9fafb;
}
</style>
