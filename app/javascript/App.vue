<template>
  <div id="app">
    <Landing v-if="!isLoggedIn" @auth-success="handleAuthSuccess" />
    <Home v-else :user="currentUser" />
  </div>
</template>

<script>
import Home from './components/Home.vue'
import Landing from './components/Landing.vue'

export default {
  components: {
    Home,
    Landing
  },

  data() {
    return {
      isLoggedIn: false,
      currentUser: null
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
