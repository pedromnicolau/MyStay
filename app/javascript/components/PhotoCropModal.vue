<template>
  <div 
    v-if="visible"
    class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
    @click.self="cancel"
  >
    <div class="bg-white rounded-lg shadow-lg max-w-2xl w-full mx-4 max-h-[90vh] overflow-y-auto">
      <!-- Header -->
      <div class="flex items-center justify-between p-6 border-b border-gray-200 sticky top-0 bg-white">
        <h2 class="text-xl font-semibold text-gray-900">Ajustar Foto de Perfil</h2>
        <button
          @click="cancel"
          class="text-gray-400 hover:text-gray-600 transition"
        >
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>

      <!-- Content -->
      <div class="p-6 space-y-6">
        <!-- Preview Container -->
        <div class="space-y-4">
          <label class="block text-sm font-medium text-gray-700">Preview da Foto</label>
          <div class="bg-gradient-to-br from-gray-50 to-gray-100 rounded-lg p-4 flex justify-center">
            <div 
              ref="canvasContainer"
              class="relative select-none transition-all"
              :class="[isDragging ? 'cursor-grabbing scale-[0.98]' : 'cursor-grab hover:scale-[1.01]']"
              style="width: 300px; height: 300px;"
              @mousedown="startDrag"
              @wheel.prevent="handleZoom"
              @mousemove="onDrag"
              @mouseup="endDrag"
              @mouseleave="endDrag"
              @touchstart="handleTouchStart"
              @touchmove="handleTouchMove"
              @touchend="endDrag"
            >
              <!-- Canvas para preview -->
              <canvas
                ref="previewCanvas"
                class="w-full h-full rounded-lg shadow-lg select-none pointer-events-none transition-shadow"
                :class="[isDragging ? 'shadow-xl border-indigo-300' : 'border-gray-300']"
                style="border-width: 3px;"
                :width="300"
                :height="300"
              ></canvas>
              <!-- Circular overlay to show how it will look as profile -->
              <div 
                class="absolute inset-0 rounded-full m-auto pointer-events-none transition-all"
                :class="[isDragging ? 'border-indigo-500 border-opacity-70' : 'border-indigo-400 border-opacity-40']"
                style="width: 280px; height: 280px; border-width: 4px;"
              ></div>
              <!-- Drag indicator -->
              <div 
                v-if="!isDragging"
                class="absolute inset-0 flex items-center justify-center pointer-events-none opacity-0 hover:opacity-100 transition-opacity bg-black bg-opacity-5 rounded-lg"
              >
                <div class="bg-white bg-opacity-90 rounded-full p-3 shadow-lg">
                  <i class="fas fa-hand-paper text-indigo-600 text-2xl"></i>
                </div>
              </div>
            </div>
          </div>
          <p class="text-xs text-gray-500 text-center">Arraste para mover a imagem • Scroll para zoom</p>
          <div 
            v-if="isDragging"
            class="flex items-center justify-center gap-2 text-sm font-medium text-indigo-600 animate-pulse"
          >
            <i class="fas fa-arrows-alt"></i>
            <span>Movendo imagem...</span>
          </div>
        </div>

        <!-- Zoom Slider -->
        <div class="space-y-2">
          <label class="block text-sm font-medium text-gray-700 flex items-center gap-2">
            <i class="fas fa-search-plus text-indigo-600"></i>
            Zoom
          </label>
          <div class="flex items-center gap-3">
            <i class="fas fa-minus text-gray-400"></i>
            <input
              v-model.number="zoom"
              type="range"
              :min="minZoom"
              max="200"
              step="5"
              class="flex-1"
              @input="updatePreview"
            />
            <i class="fas fa-plus text-gray-400"></i>
            <span class="text-sm font-medium text-gray-700 w-12 text-right">{{ zoom }}%</span>
          </div>
        </div>
      </div>

      <!-- Footer -->
      <div class="border-t border-gray-200 p-6 bg-gray-50 sticky bottom-0 flex justify-end gap-3">
        <button
          type="button"
          @click="cancel"
          class="px-6 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition font-medium"
        >
          Cancelar
        </button>
        <button
          type="button"
          @click="confirm"
          class="px-6 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition font-medium"
        >
          <i class="fas fa-check mr-2"></i>
          Usar esta foto
        </button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PhotoCropModal',
  props: {
    visible: {
      type: Boolean,
      default: false
    },
    previewUrl: {
      type: String,
      required: true
    },
    name: {
      type: String,
      default: ''
    }
  },
  emits: ['confirm', 'cancel'],
  data() {
    return {
      zoom: 100,
      rotation: 0,
      offsetX: 0,
      offsetY: 0,
      image: null,
      isDragging: false,
      dragStartX: 0,
      dragStartY: 0,
      dragStartOffsetX: 0,
      dragStartOffsetY: 0,
      minZoom: 20
    }
  },
  watch: {
    visible(newVal) {
      if (newVal) {
        this.resetAdjustments()
        this.$nextTick(() => {
          this.loadImage()
        })
      }
    }
  },
  methods: {
    loadImage() {
      const img = new Image()
      img.onload = () => {
        this.image = img
        
        const circleSize = 280
        const minDim = Math.min(img.width, img.height)
        
        // Calcula o zoom mínimo para que a menor dimensão cubra o círculo
        // Isso permite o máximo de área da foto no recorte
        this.minZoom = Math.ceil((circleSize / minDim) * 100)
        
        // Garante que o zoom inicial seja pelo menos o mínimo
        if (this.zoom < this.minZoom) {
          this.zoom = this.minZoom
        }
        
        this.updatePreview()
      }
      img.src = this.previewUrl
    },
    updatePreview() {
      if (!this.image || !this.$refs.previewCanvas) return

      const canvas = this.$refs.previewCanvas
      const ctx = canvas.getContext('2d')
      const previewSize = 300
      const circleSize = 280

      ctx.fillStyle = '#ffffff'
      ctx.fillRect(0, 0, previewSize, previewSize)

      ctx.save()

      const offsetX = (previewSize - circleSize) / 2
      const offsetY = (previewSize - circleSize) / 2

      ctx.translate(previewSize / 2, previewSize / 2)
      ctx.rotate((this.rotation * Math.PI) / 180)

      const scale = this.zoom / 100
      ctx.scale(scale, scale)

      const img = this.image
      const imgWidth = img.width
      const imgHeight = img.height

      const minDim = Math.min(imgWidth, imgHeight)
      const startX = (imgWidth - minDim) / 2 + this.offsetX
      const startY = (imgHeight - minDim) / 2 + this.offsetY

      ctx.drawImage(
        img,
        startX,
        startY,
        minDim,
        minDim,
        -(minDim / 2),
        -(minDim / 2),
        minDim,
        minDim
      )

      ctx.restore()
    },
    resetPosition() {
      this.offsetX = 0
      this.offsetY = 0
      this.updatePreview()
    },
    resetAdjustments() {
      this.zoom = 100
      this.rotation = 0
      this.offsetX = 0
      this.offsetY = 0
      this.updatePreview()
    },
    startDrag(event) {
      event.preventDefault()
      this.isDragging = true
      this.dragStartX = event.clientX
      this.dragStartY = event.clientY
      this.dragStartOffsetX = this.offsetX
      this.dragStartOffsetY = this.offsetY
      
      // Adicionar cursor grabbing ao body para melhor UX
      document.body.style.cursor = 'grabbing'
      document.body.style.userSelect = 'none'
    },
    onDrag(event) {
      if (!this.isDragging || !this.image) return

      const deltaX = event.clientX - this.dragStartX
      const deltaY = event.clientY - this.dragStartY

      const scale = this.zoom / 100
      const img = this.image
      const minDim = Math.min(img.width, img.height)
      const circleSize = 280
      const previewSize = 300
      
      // Calcula o raio da área circular no espaço da imagem original
      const circleRadiusInImageSpace = (circleSize / 2) / scale
      
      // Limita o offset para que o círculo nunca saia da área da imagem
      const maxOffset = (minDim / 2) - circleRadiusInImageSpace

      let newOffsetX = this.dragStartOffsetX - deltaX
      let newOffsetY = this.dragStartOffsetY - deltaY

      newOffsetX = Math.max(-maxOffset, Math.min(maxOffset, newOffsetX))
      newOffsetY = Math.max(-maxOffset, Math.min(maxOffset, newOffsetY))

      this.offsetX = newOffsetX
      this.offsetY = newOffsetY

      this.updatePreview()
    },
    endDrag() {
      if (!this.isDragging) return
      
      this.isDragging = false
      document.body.style.cursor = ''
      document.body.style.userSelect = ''
    },
    handleTouchStart(event) {
      if (event.touches.length !== 1) return
      event.preventDefault()
      
      this.isDragging = true
      const touch = event.touches[0]
      this.dragStartX = touch.clientX
      this.dragStartY = touch.clientY
      this.dragStartOffsetX = this.offsetX
      this.dragStartOffsetY = this.offsetY
    },
    handleTouchMove(event) {
      if (!this.isDragging || event.touches.length !== 1 || !this.image) return
      event.preventDefault()
      
      const touch = event.touches[0]
      const deltaX = touch.clientX - this.dragStartX
      const deltaY = touch.clientY - this.dragStartY

      const scale = this.zoom / 100
      const img = this.image
      const minDim = Math.min(img.width, img.height)
      const circleSize = 280
      
      // Calcula o raio da área circular no espaço da imagem original
      const circleRadiusInImageSpace = (circleSize / 2) / scale
      
      // Limita o offset para que o círculo nunca saia da área da imagem
      const maxOffset = (minDim / 2) - circleRadiusInImageSpace

      let newOffsetX = this.dragStartOffsetX - deltaX
      let newOffsetY = this.dragStartOffsetY - deltaY

      newOffsetX = Math.max(-maxOffset, Math.min(maxOffset, newOffsetX))
      newOffsetY = Math.max(-maxOffset, Math.min(maxOffset, newOffsetY))

      this.offsetX = newOffsetX
      this.offsetY = newOffsetY

      this.updatePreview()
    },
    handleZoom(event) {
      const delta = event.deltaY > 0 ? -5 : 5
      this.zoom = Math.max(this.minZoom, Math.min(200, this.zoom + delta))
      this.updatePreview()
    },
    confirm() {
      if (!this.$refs.previewCanvas || !this.image) return

      const previewSize = 300
      const outputSize = 500
      const zoomFactor = outputSize / previewSize

      const croppingCanvas = document.createElement('canvas')
      croppingCanvas.width = outputSize
      croppingCanvas.height = outputSize
      const croppingCtx = croppingCanvas.getContext('2d')

      croppingCtx.save()

      croppingCtx.translate(outputSize / 2, outputSize / 2)

      croppingCtx.rotate((this.rotation * Math.PI) / 180)

      const scale = (this.zoom * zoomFactor) / 100
      croppingCtx.scale(scale, scale)

      const img = this.image
      const imgWidth = img.width
      const imgHeight = img.height

      const minDim = Math.min(imgWidth, imgHeight)
      const startX = (imgWidth - minDim) / 2 + this.offsetX
      const startY = (imgHeight - minDim) / 2 + this.offsetY

      croppingCtx.drawImage(
        img,
        startX,
        startY,
        minDim,
        minDim,
        -(minDim / 2),
        -(minDim / 2),
        minDim,
        minDim
      )

      croppingCtx.restore()

      const croppedDataUrl = croppingCanvas.toDataURL('image/jpeg', 0.95)

      this.$emit('confirm', {
        zoom: this.zoom,
        rotation: this.rotation,
        offsetX: this.offsetX,
        offsetY: this.offsetY,
        croppedDataUrl: croppedDataUrl
      })
    },    cancel() {
      this.$emit('cancel')
    }
  }
}
</script>
