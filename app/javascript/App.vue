<template>
  <div id="app">
    <Auth v-if="!isLoggedIn" @login="handleLogin" />
    <Home v-else />
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
      isLoggedIn: false
    }
  },

  mounted() {
    const token = localStorage.getItem('token')
    if (token) {
      this.isLoggedIn = true
    }
  },

  methods: {
    handleLogin() {
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
