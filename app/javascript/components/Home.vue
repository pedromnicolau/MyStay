<template>
  <div class="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center p-4">
    <div class="text-center">
      <h1 class="text-4xl font-bold text-gray-900 mb-4">MyStay</h1>
      <p class="text-gray-600 text-lg mb-8">Página inicial</p>
      <button
        @click="logout"
        class="bg-red-600 text-white px-6 py-3 rounded-lg hover:bg-red-700 transition"
      >
        Logout
      </button>
    </div>
  </div>
</template>

<script>
export default {
  methods: {
    logout() {
      localStorage.removeItem('token')
      localStorage.removeItem('user')
      window.location.reload()
    }
  }
}
</script>
