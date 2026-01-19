<template>
  <div id="app">
    <Auth v-if="!isLoggedIn" @login="handleLogin" />
    <Home v-else :user="currentUser" />
  </div>
</template>

<script>
import Auth from './components/Auth.vue'
import Home from './components/Home.vue'

export default {
  components: {
    Auth,
    Home
  },

  data() {
    return {
      isLoggedIn: false,
      currentUser: null
    }
  },

  mounted() {
    const token = localStorage.getItem('token')
    const user = localStorage.getItem('user')
    
    if (token && user) {
      this.currentUser = JSON.parse(user)
      this.isLoggedIn = true
    }
  },

  methods: {
    handleLogin(user) {
      this.currentUser = user
      this.isLoggedIn = true
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
