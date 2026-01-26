<template>
  <div
    v-if="visible"
    class="fixed inset-0 bg-black bg-opacity-95 z-[100] flex flex-col"
    @click.self="close"
  >
    <div class="flex items-center justify-between px-4 py-3 bg-gray-900 border-b border-gray-700">
      <div class="text-gray-300 text-sm font-medium">
        {{ altText }}
      </div>
      <div class="flex items-center space-x-2">
        <button
          class="px-2 py-1 bg-gray-700 text-gray-100 rounded hover:bg-gray-600 transition"
          @click="zoomOut"
          title="Diminuir zoom"
        >
          −
        </button>
        <button
          class="px-3 py-1 bg-gray-700 text-gray-100 rounded hover:bg-gray-600 transition"
          @click="resetZoom"
          :title="`Resetar zoom (${Math.round(zoom * 100)}%)`"
        >
          {{ Math.round(zoom * 100) }}%
        </button>
        <button
          class="px-2 py-1 bg-gray-700 text-gray-100 rounded hover:bg-gray-600 transition"
          @click="zoomIn"
          title="Aumentar zoom"
        >
          +
        </button>
        <a
          :href="imageUrl"
          :download="`${getFilename()}.jpg`"
          class="px-3 py-1 bg-indigo-600 text-white rounded hover:bg-indigo-500 transition"
          title="Baixar foto"
        >
          Baixar
        </a>
        <button
          class="p-2 text-gray-300 hover:text-white hover:bg-gray-700 rounded transition"
          @click="close"
          title="Fechar"
        >
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>
    </div>
    <div 
      class="flex-1 flex items-center justify-center bg-gray-950 p-4 overflow-auto"
      @wheel.prevent="handleZoom"
      @click.self="close"
    >
      <img
        :src="imageUrl"
        :alt="altText"
        class="max-h-[75vh] max-w-full object-contain select-none transition-transform"
        :style="{ transform: `scale(${zoom})` }"
      />
    </div>
  </div>
</template>

<script>
export default {
  name: 'ImageLightbox',
  props: {
    visible: {
      type: Boolean,
      default: false
    },
    imageUrl: {
      type: String,
      required: true
    },
    altText: {
      type: String,
      default: 'Imagem'
    }
  },
  emits: ['close'],
  data() {
    return {
      zoom: 1,
      minZoom: 0.5,
      maxZoom: 3
    }
  },
  watch: {
    visible(newVal) {
      if (newVal) {
        this.zoom = 1
      }
    }
  },
  methods: {
    close() {
      this.$emit('close')
    },
    zoomIn() {
      this.zoom = Math.min(this.zoom + 0.2, this.maxZoom)
    },
    zoomOut() {
      this.zoom = Math.max(this.zoom - 0.2, this.minZoom)
    },
    resetZoom() {
      this.zoom = 1
    },
    handleZoom(event) {
      event.preventDefault()
      const delta = event.deltaY > 0 ? -0.1 : 0.1
      this.zoom = Math.max(this.minZoom, Math.min(this.maxZoom, this.zoom + delta))
    },
    getFilename() {
      return this.altText.split(' - ')[0].replace(/\s+/g, '_').toLowerCase() || 'foto_perfil'
    }
  }
}
</script>
