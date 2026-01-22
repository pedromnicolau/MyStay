<template>
  <div>
    <div class="space-y-3">
      <!-- Grid de Anexos Existentes e Novos -->
      <div v-if="existingList.length || newList.length" class="flex flex-wrap gap-1">
        <!-- Anexos Existentes -->
        <template v-for="(attachment, existingIdx) in existingList" :key="`existing-${attachment.id}`">
          <div
            :draggable="enableReorder"
            @dragstart="startDrag($event, 'existing', existingIdx)"
            @dragover.prevent="dragOver($event, 'existing', existingIdx)"
            @drop.prevent="drop($event, 'existing', existingIdx)"
            @dragleave="clearDragOver"
            @dragend="endDrag"
            class="relative w-28 h-28 rounded-lg overflow-hidden border-2 bg-gray-50 transition"
            :class="{ 
              'cursor-move': enableReorder,
              'cursor-pointer': enableLightbox,
              'opacity-50 bg-indigo-100 border-indigo-400': dragState.from === 'existing' && dragState.fromIdx === existingIdx,
              'border-indigo-500 ring-2 ring-indigo-300': dragState.overType === 'existing' && dragState.overIdx === existingIdx,
              'border-purple-500 ring-2 ring-purple-300': enableReorder && existingIdx === 0,
              'border-gray-200': !enableReorder || existingIdx !== 0
            }"
            @click="handleClick(existingIdx)"
          >
            <button
              type="button"
              @click.stop="removeExisting(attachment)"
              class="absolute top-1 right-1 bg-black bg-opacity-50 text-white rounded-full w-6 h-6 flex items-center justify-center text-xs z-10 cursor-pointer hover:bg-opacity-70"
              :draggable="false"
            >
              ×
            </button>
            <template v-if="isImage(attachment)">
              <img :src="getPreviewUrl(attachment)" alt="Anexo" class="w-full h-full object-cover pointer-events-none" />
            </template>
            <template v-else-if="isVideo(attachment)">
              <video :src="getPreviewUrl(attachment)" class="w-full h-full object-cover pointer-events-none" muted loop></video>
              <span class="absolute bottom-1 left-1 text-[10px] bg-black bg-opacity-60 text-white px-1 rounded">Vídeo</span>
            </template>
            <template v-else>
              <div class="w-full h-full flex items-center justify-center bg-gray-200">
                <svg class="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
              </div>
              <span class="absolute bottom-1 left-1 text-[10px] bg-black bg-opacity-60 text-white px-1 rounded">{{ getFileExtension(attachment.filename || attachment.name) }}</span>
            </template>
          </div>

          <!-- Drop zone (somente se reorder habilitado) -->
          <div
            v-if="enableReorder"
            @dragover.prevent="dragOverZone($event, 'existing', existingIdx, 'after')"
            @drop.prevent="dropInZone($event, 'existing', existingIdx, 'after')"
            @dragleave="clearDropZone"
            class="w-3 h-28 transition-all"
            :class="dropZoneActive === `existing-${existingIdx}-after` ? 'bg-indigo-400 w-6 rounded-lg' : 'bg-transparent'"
          ></div>
        </template>

        <!-- Anexos Novos -->
        <template v-for="(file, newIdx) in newList" :key="`new-${file.name}-${file.lastModified}`">
          <div
            :draggable="enableReorder"
            @dragstart="startDrag($event, 'new', newIdx)"
            @dragover.prevent="dragOver($event, 'new', newIdx)"
            @drop.prevent="drop($event, 'new', newIdx)"
            @dragleave="clearDragOver"
            @dragend="endDrag"
            class="relative w-28 h-28 rounded-lg overflow-hidden border-2 border-indigo-200 bg-indigo-50 transition"
            :class="{ 
              'cursor-move': enableReorder,
              'cursor-pointer': enableLightbox,
              'opacity-50 bg-indigo-100 border-indigo-600': dragState.from === 'new' && dragState.fromIdx === newIdx,
              'border-indigo-500 ring-2 ring-indigo-300': dragState.overType === 'new' && dragState.overIdx === newIdx
            }"
            @click="handleClick(existingList.length + newIdx)"
          >
            <button
              type="button"
              @click.stop="removeNew(file)"
              class="absolute top-1 right-1 bg-indigo-600 text-white rounded-full w-6 h-6 flex items-center justify-center text-xs z-10 cursor-pointer hover:bg-indigo-700"
              :draggable="false"
            >
              ×
            </button>
            <template v-if="isImage(file)">
              <img :src="getPreviewUrl(file)" alt="Anexo" class="w-full h-full object-cover pointer-events-none" />
            </template>
            <template v-else-if="isVideo(file)">
              <video :src="getPreviewUrl(file)" class="w-full h-full object-cover pointer-events-none" muted loop></video>
              <span class="absolute bottom-1 left-1 text-[10px] bg-indigo-600 text-white px-1 rounded">Novo</span>
            </template>
            <template v-else>
              <div class="w-full h-full flex items-center justify-center bg-indigo-100">
                <svg class="w-8 h-8 text-indigo-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
              </div>
              <span class="absolute bottom-1 left-1 text-[10px] bg-indigo-600 text-white px-1 rounded">{{ getFileExtension(file.name) }}</span>
            </template>
          </div>

          <!-- Drop zone (somente se reorder habilitado) -->
          <div
            v-if="enableReorder"
            @dragover.prevent="dragOverZone($event, 'new', newIdx, 'after')"
            @drop.prevent="dropInZone($event, 'new', newIdx, 'after')"
            @dragleave="clearDropZone"
            class="w-3 h-28 transition-all"
            :class="dropZoneActive === `new-${newIdx}-after` ? 'bg-indigo-400 w-6 rounded-lg' : 'bg-transparent'"
          ></div>
        </template>
      </div>

      <!-- Botão para adicionar anexos -->
      <label
        class="flex items-center justify-center w-full px-4 py-3 border-2 border-dashed border-gray-300 rounded-lg text-sm text-gray-600 hover:border-indigo-400 hover:text-indigo-600 cursor-pointer bg-gray-50"
        @dragenter.prevent
        @dragover.prevent
        @drop.prevent="handleDrop"
      >
        <input
          type="file"
          :accept="acceptedTypes"
          class="hidden"
          multiple
          @change="handleFileSelect"
        />
        <div class="flex items-center space-x-2">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
          </svg>
          <span>{{ addButtonText }}</span>
        </div>
      </label>
    </div>

    <!-- Lightbox integrado -->
    <div
      v-if="lightbox.open"
      class="fixed inset-0 bg-black bg-opacity-95 z-[100] flex flex-col"
      @click.self="closeLightbox"
    >
      <div class="flex items-center justify-between px-4 py-3 bg-gray-900 border-b border-gray-700">
        <div class="flex items-center space-x-3">
          <button
            class="p-2 text-gray-300 hover:text-white hover:bg-gray-700 rounded transition"
            @click="prevLightbox"
          >
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
            </svg>
          </button>
          <span class="text-gray-300 text-sm">
            {{ lightbox.index + 1 }} / {{ lightbox.items.length }}
          </span>
          <button
            class="p-2 text-gray-300 hover:text-white hover:bg-gray-700 rounded transition"
            @click="nextLightbox"
          >
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
            </svg>
          </button>
        </div>
        <div class="flex items-center space-x-2">
          <button
            v-if="canZoom()"
            class="px-2 py-1 bg-gray-700 text-gray-100 rounded hover:bg-gray-600"
            @click.stop="zoomOut"
          >-</button>
          <button
            v-if="canZoom()"
            class="px-2 py-1 bg-gray-700 text-gray-100 rounded hover:bg-gray-600"
            @click.stop="resetZoom"
          >{{ Math.round(lightbox.zoom * 100) }}%</button>
          <button
            v-if="canZoom()"
            class="px-2 py-1 bg-gray-700 text-gray-100 rounded hover:bg-gray-600"
            @click.stop="zoomIn"
          >+</button>
          <a
            :href="currentPreviewUrl()"
            :download="currentFilename()"
            class="px-3 py-1 bg-indigo-600 text-white rounded hover:bg-indigo-500"
            @click.stop
          >
            Baixar
          </a>
          <button
            class="p-2 text-gray-300 hover:text-white hover:bg-gray-700 rounded transition"
            @click="closeLightbox"
          >
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
      </div>
      <div class="flex-1 flex items-center justify-center bg-gray-950 p-4 overflow-auto">
        <template v-if="isImage(currentLightboxItem())">
          <img
            :src="currentPreviewUrl()"
            class="max-h-[75vh] max-w-full object-contain select-none cursor-grab"
            :class="{ 'cursor-grabbing': lightbox.isDragging }"
            :style="{ transform: `translate(${lightbox.panX}px, ${lightbox.panY}px) scale(${lightbox.zoom})` }"
            @mousedown="startLightboxDrag"
            @mousemove="onLightboxDrag"
            @mouseup="stopLightboxDrag"
            @mouseleave="stopLightboxDrag"
            @wheel="handleWheel"
            @dragstart.prevent
            alt="Pré-visualização"
          />
        </template>
        <template v-else>
          <video
            :src="currentPreviewUrl()"
            class="max-h-[75vh] max-w-full object-contain"
            controls
            autoplay
          ></video>
        </template>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AttachmentManager',
  props: {
    modelValue: {
      type: Array,
      default: () => []
    },
    removeAttachmentIds: {
      type: Array,
      default: () => []
    },
    acceptedTypes: {
      type: String,
      default: '*'
    },
    enableReorder: {
      type: Boolean,
      default: false
    },
    enableLightbox: {
      type: Boolean,
      default: false
    },
    addButtonText: {
      type: String,
      default: 'Clique ou arraste arquivos para adicionar anexos'
    }
  },
  emits: ['update:modelValue', 'update:removeAttachmentIds'],
  data() {
    return {
      dragState: {
        from: null,
        fromIdx: null,
        overType: null,
        overIdx: null
      },
      dropZoneActive: null,
      lightbox: {
        open: false,
        items: [],
        index: 0,
        zoom: 1,
        panX: 0,
        panY: 0,
        isDragging: false,
        dragStartX: 0,
        dragStartY: 0
      }
    }
  },
  computed: {
    existingList() {
      const items = this.modelValue.filter(item => !this.isFile(item))
      return items
    },
    newList() {
      return this.modelValue.filter(item => this.isFile(item))
    }
  },
  methods: {
    isFile(item) {
      return (typeof File !== 'undefined' && item instanceof File) ||
        (typeof Blob !== 'undefined' && item instanceof Blob)
    },

    isImage(attachment) {
      const contentType = attachment.content_type || attachment.type || ''
      if (contentType) return contentType.startsWith('image/')
      const url = this.getPreviewUrl(attachment)
      return typeof url === 'string' && url.match(/\.(png|jpe?g|gif|webp|bmp|avif)(\?|$)/i)
    },

    isVideo(attachment) {
      const contentType = attachment.content_type || attachment.type || ''
      if (contentType) return contentType.startsWith('video/')
      const url = this.getPreviewUrl(attachment)
      return typeof url === 'string' && url.match(/\.(mp4|mov|webm|ogg|mkv)(\?|$)/i)
    },

    getPreviewUrl(attachment) {
      if (this.isFile(attachment)) {
        if (!attachment.previewUrl) {
          attachment.previewUrl = URL.createObjectURL(attachment)
        }
        return attachment.previewUrl
      }
      return attachment.url || attachment.previewUrl || ''
    },

    getFileExtension(filename) {
      if (!filename) return ''
      return filename.split('.').pop().toUpperCase()
    },

    handleFileSelect(event) {
      const files = Array.from(event.target.files || [])
      this.addFiles(files)
      event.target.value = ''
    },

    handleDrop(event) {
      const files = Array.from(event.dataTransfer?.files || [])
      this.addFiles(files)
    },

    addFiles(files) {
      const newAttachments = [...this.modelValue, ...files]
      this.$emit('update:modelValue', newAttachments)
    },

    removeExisting(attachment) {
      const newRemoveIds = [...this.removeAttachmentIds]
      if (attachment.id && !newRemoveIds.includes(attachment.id)) {
        newRemoveIds.push(attachment.id)
      }
      this.$emit('update:removeAttachmentIds', newRemoveIds)

      const newAttachments = this.modelValue.filter(item => item.id !== attachment.id)
      this.$emit('update:modelValue', newAttachments)
    },

    removeNew(file) {
      if (file.previewUrl) {
        URL.revokeObjectURL(file.previewUrl)
      }
      const newAttachments = this.modelValue.filter(item => item !== file)
      this.$emit('update:modelValue', newAttachments)
    },

    startDrag(event, type, index) {
      if (!this.enableReorder) return
      this.dragState.from = type
      this.dragState.fromIdx = index
      event.dataTransfer.effectAllowed = 'move'
    },

    dragOver(event, type, index) {
      if (!this.enableReorder) return
      event.dataTransfer.dropEffect = 'move'
      this.dragState.overType = type
      this.dragState.overIdx = index
    },

    clearDragOver() {
      this.dragState.overType = null
      this.dragState.overIdx = null
    },

    drop(event, toType, toIdx) {
      if (!this.enableReorder) return
      const fromType = this.dragState.from
      const fromIdx = this.dragState.fromIdx

      if (fromType === null || fromIdx === null) return
      if (fromType === toType && fromIdx === toIdx) return

      this.swapAttachments(fromType, fromIdx, toType, toIdx)
      this.endDrag()
    },

    swapAttachments(fromType, fromIdx, toType, toIdx) {
      const allAttachments = [...this.modelValue]
      
      let draggedItem = null
      if (fromType === 'existing') {
        draggedItem = this.existingList[fromIdx]
      } else {
        draggedItem = this.newList[fromIdx]
      }

      if (!draggedItem) return

      const fromRealIdx = allAttachments.indexOf(draggedItem)
      if (fromRealIdx === -1) return

      let targetItem = null
      if (toType === 'existing') {
        targetItem = this.existingList[toIdx]
      } else {
        targetItem = this.newList[toIdx]
      }

      const toRealIdx = targetItem ? allAttachments.indexOf(targetItem) : allAttachments.length

      // Swap
      const temp = allAttachments[fromRealIdx]
      allAttachments[fromRealIdx] = allAttachments[toRealIdx]
      allAttachments[toRealIdx] = temp

      this.$emit('update:modelValue', allAttachments)
    },

    dragOverZone(event, type, index, position) {
      if (!this.enableReorder) return
      event.dataTransfer.dropEffect = 'move'
      this.dropZoneActive = `${type}-${index}-${position}`
    },

    clearDropZone() {
      this.dropZoneActive = null
    },

    dropInZone(event, toType, toIdx, position) {
      if (!this.enableReorder) return
      const fromType = this.dragState.from
      const fromIdx = this.dragState.fromIdx

      if (fromType === null || fromIdx === null) return

      const targetIdx = toIdx + 1
      this.insertAttachment(fromType, fromIdx, toType, targetIdx)
      this.endDrag()
    },

    insertAttachment(fromType, fromIdx, toType, targetIdx) {
      const allAttachments = [...this.modelValue]
      
      let draggedItem = null
      if (fromType === 'existing') {
        draggedItem = this.existingList[fromIdx]
      } else {
        draggedItem = this.newList[fromIdx]
      }

      if (!draggedItem) return

      const fromRealIdx = allAttachments.indexOf(draggedItem)
      if (fromRealIdx === -1) return

      let toRealIdx = 0
      if (toType === 'existing' && targetIdx < this.existingList.length) {
        toRealIdx = allAttachments.indexOf(this.existingList[targetIdx])
      } else if (toType === 'new' && targetIdx < this.newList.length) {
        toRealIdx = allAttachments.indexOf(this.newList[targetIdx])
      } else {
        toRealIdx = allAttachments.length
      }

      const [removed] = allAttachments.splice(fromRealIdx, 1)
      const insertIdx = fromRealIdx < toRealIdx ? toRealIdx - 1 : toRealIdx
      allAttachments.splice(insertIdx, 0, removed)

      this.$emit('update:modelValue', allAttachments)
    },

    endDrag() {
      this.dragState.from = null
      this.dragState.fromIdx = null
      this.dragState.overType = null
      this.dragState.overIdx = null
      this.dropZoneActive = null
    },

    handleClick(index) {
      if (!this.enableLightbox) return
      this.openLightbox(index)
    },

    // Métodos de Lightbox
    openLightbox(index) {
      const allItems = [...this.modelValue]
      const items = allItems.map(item => this.ensurePreview(item))
      if (!items.length) return

      this.lightbox.items = items
      this.lightbox.index = index
      this.lightbox.zoom = 1
      this.lightbox.panX = 0
      this.lightbox.panY = 0
      this.lightbox.open = true
    },

    closeLightbox() {
      this.lightbox.open = false
      this.lightbox.items = []
      this.lightbox.index = 0
      this.lightbox.zoom = 1
      this.lightbox.panX = 0
      this.lightbox.panY = 0
    },

    nextLightbox() {
      if (!this.lightbox.items.length) return
      this.lightbox.index = (this.lightbox.index + 1) % this.lightbox.items.length
      this.lightbox.zoom = 1
      this.lightbox.panX = 0
      this.lightbox.panY = 0
    },

    prevLightbox() {
      if (!this.lightbox.items.length) return
      this.lightbox.index = (this.lightbox.index - 1 + this.lightbox.items.length) % this.lightbox.items.length
      this.lightbox.zoom = 1
      this.lightbox.panX = 0
      this.lightbox.panY = 0
    },

    currentLightboxItem() {
      return this.lightbox.items[this.lightbox.index] || {}
    },

    currentPreviewUrl() {
      return this.getPreviewUrl(this.currentLightboxItem())
    },

    currentFilename() {
      const item = this.currentLightboxItem()
      return item.filename || item.name || 'download'
    },

    ensurePreview(item) {
      if (this.isFile(item) && !item.previewUrl) {
        item.previewUrl = URL.createObjectURL(item)
      }
      return item
    },

    canZoom() {
      return this.isImage(this.currentLightboxItem())
    },

    zoomIn() {
      if (this.canZoom()) {
        this.lightbox.zoom = Math.min(this.lightbox.zoom + 0.25, 5)
      }
    },

    zoomOut() {
      if (this.canZoom()) {
        this.lightbox.zoom = Math.max(this.lightbox.zoom - 0.25, 0.5)
      }
    },

    resetZoom() {
      this.lightbox.zoom = 1
      this.lightbox.panX = 0
      this.lightbox.panY = 0
    },

    startLightboxDrag(event) {
      if (!this.canZoom() || this.lightbox.zoom <= 1) return
      this.lightbox.isDragging = true
      this.lightbox.dragStartX = event.clientX - this.lightbox.panX
      this.lightbox.dragStartY = event.clientY - this.lightbox.panY
    },

    onLightboxDrag(event) {
      if (!this.lightbox.isDragging) return
      this.lightbox.panX = event.clientX - this.lightbox.dragStartX
      this.lightbox.panY = event.clientY - this.lightbox.dragStartY
    },

    stopLightboxDrag() {
      this.lightbox.isDragging = false
    },

    handleWheel(event) {
      if (!this.canZoom()) return
      event.preventDefault()
      const delta = event.deltaY > 0 ? -0.1 : 0.1
      this.lightbox.zoom = Math.max(0.5, Math.min(5, this.lightbox.zoom + delta))
    }
  }
}
</script>
