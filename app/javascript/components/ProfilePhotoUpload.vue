<template>
  <div class="space-y-4">
    <!-- Foto de Perfil Preview -->
    <div class="flex flex-col items-center">
      <div class="relative inline-block">
        <!-- Avatar Circle -->
        <div class="w-32 h-32 rounded-full overflow-hidden bg-gradient-to-br from-indigo-100 to-indigo-200 flex items-center justify-center border-4 border-white shadow-lg">
          <img 
            v-if="previewUrl || modelValue" 
            :src="previewUrl || modelValue" 
            :alt="name || 'Foto de perfil'"
            class="w-full h-full object-cover"
          />
          <template v-else>
            <svg class="w-16 h-16 text-indigo-300" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clip-rule="evenodd" />
            </svg>
          </template>
        </div>

        <!-- Upload Button (Camera Icon) -->
        <div class="relative">
          <button
            type="button"
            @click="showCameraMenu = !showCameraMenu"
            class="absolute bottom-0 right-0 bg-indigo-600 text-white rounded-full p-3 shadow-lg hover:bg-indigo-700 transition-all duration-200 transform hover:scale-110 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
            :disabled="uploading"
            title="Opções de foto"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
            </svg>
          </button>

          <!-- Camera Menu Dropdown -->
          <transition
            enter-active-class="transition ease-out duration-100"
            enter-from-class="transform opacity-0 scale-95"
            enter-to-class="transform opacity-100 scale-100"
            leave-active-class="transition ease-in duration-75"
            leave-from-class="transform opacity-100 scale-100"
            leave-to-class="transform opacity-0 scale-95"
          >
            <div
              v-if="showCameraMenu"
              class="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-lg py-2 z-10 border border-gray-100"
              @click="showCameraMenu = false"
            >
              <button
                v-if="modelValue"
                type="button"
                @click="viewPhoto"
                class="w-full text-left flex items-center px-4 py-2 text-sm text-gray-700 hover:bg-indigo-50 hover:text-indigo-600 transition"
              >
                <svg class="w-4 h-4 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                </svg>
                <span>Ver Foto</span>
              </button>
              <button
                type="button"
                @click="triggerFileInput"
                class="w-full text-left flex items-center px-4 py-2 text-sm text-gray-700 hover:bg-indigo-50 hover:text-indigo-600 transition"
              >
                <svg class="w-4 h-4 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                </svg>
                <span>Nova Foto</span>
              </button>
              <div v-if="modelValue" class="border-t border-gray-100 my-1"></div>
              <button
                v-if="modelValue"
                type="button"
                @click="deletePhoto"
                class="w-full text-left flex items-center px-4 py-2 text-sm text-red-600 hover:bg-red-50 transition"
              >
                <svg class="w-4 h-4 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                </svg>
                <span>Excluir Foto</span>
              </button>
            </div>
          </transition>
        </div>

        <!-- Loading Indicator -->
        <div 
          v-if="uploading"
          class="absolute inset-0 rounded-full bg-black bg-opacity-40 flex items-center justify-center"
        >
          <div class="animate-spin rounded-full h-8 w-8 border-4 border-white border-t-indigo-600"></div>
        </div>
      </div>

      <!-- File Input (Hidden) -->
      <input
        ref="fileInput"
        type="file"
        accept="image/*"
        class="hidden"
        @change="handleFileSelect"
        :disabled="uploading"
      />

      <!-- Name Display -->
      <p v-if="name" class="mt-4 text-lg font-semibold text-gray-900 text-center">{{ name }}</p>
    </div>

    <!-- Photo Info -->
    <div v-if="fileInfo" class="bg-blue-50 border border-blue-200 rounded-lg p-3 text-sm text-gray-700">
      <div class="flex items-start gap-2">
        <svg class="w-5 h-5 text-blue-600 mt-0.5 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M18 5v8a2 2 0 01-2 2h-5l-5 4v-4H4a2 2 0 01-2-2V5a2 2 0 012-2h12a2 2 0 012 2zm-11-1a1 1 0 11-2 0 1 1 0 012 0z" clip-rule="evenodd" />
        </svg>
        <div>
          <p class="font-medium">{{ fileInfo.name }}</p>
          <p class="text-xs text-gray-600">{{ formatFileSize(fileInfo.size) }}</p>
        </div>
      </div>
    </div>

    <!-- Error Message -->
    <div v-if="error" class="bg-red-50 border border-red-200 rounded-lg p-4 flex items-start gap-3">
      <svg class="w-5 h-5 text-red-600 mt-0.5 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
      </svg>
      <div>
        <p class="font-medium text-red-900">{{ error }}</p>
      </div>
    </div>

    <!-- Success Message -->
    <div v-if="success" class="bg-green-50 border border-green-200 rounded-lg p-4 flex items-start gap-3">
      <svg class="w-5 h-5 text-green-600 mt-0.5 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
      </svg>
      <p class="font-medium text-green-900">{{ success }}</p>
    </div>

    <!-- Action Buttons -->
    <div class="flex gap-3">
      <button
        v-if="previewUrl"
        type="button"
        @click="showCropModal = true"
        :disabled="uploading"
        class="flex-1 bg-indigo-600 text-white font-medium py-2 px-4 rounded-lg hover:bg-indigo-700 transition disabled:opacity-50"
      >
        <i class="fas fa-crop-alt mr-2"></i>
        {{ uploading ? 'Ajustando...' : 'Ajustar Foto' }}
      </button>
      <button
        v-if="previewUrl"
        type="button"
        @click="confirmUpload"
        :disabled="uploading"
        class="flex-1 bg-green-600 text-white font-medium py-2 px-4 rounded-lg hover:bg-green-700 transition disabled:opacity-50"
      >
        <i class="fas fa-check mr-2"></i>
        {{ uploading ? 'Usando...' : 'Usar esta foto' }}
      </button>
    </div>

    <!-- Crop Modal -->
    <PhotoCropModal
      :visible="showCropModal"
      :preview-url="previewUrl"
      :name="name"
      @confirm="handleCropConfirm"
      @cancel="showCropModal = false"
    />

    <!-- Image Lightbox -->
    <ImageLightbox
      :visible="showLightbox"
      :image-url="modelValue"
      :alt-text="`${name} - Foto de Perfil`"
      @close="showLightbox = false"
    />
  </div>
</template>

<script>
import PhotoCropModal from './PhotoCropModal.vue'
import ImageLightbox from './ImageLightbox.vue'
import { useApi } from '../composables/useApi.js'

export default {
  name: 'ProfilePhotoUpload',
  components: {
    PhotoCropModal,
    ImageLightbox
  },
  props: {
    modelValue: {
      type: String,
      default: ''
    },
    name: {
      type: String,
      default: ''
    }
  },
  emits: ['update:modelValue', 'upload-success', 'upload-error'],
  data() {
    return {
      previewUrl: null,
      fileInfo: null,
      uploading: false,
      isDragActive: false,
      error: '',
      success: '',
      selectedFile: null,
      showCropModal: false,
      showCameraMenu: false,
      showLightbox: false,
      maxFileSize: 5 * 1024 * 1024
    }
  },
  methods: {
    triggerFileInput() {
      this.$refs.fileInput.click()
    },
    handleFileSelect(event) {
      const file = event.target.files?.[0]
      if (file) {
        this.processFile(file)
      }
    },
    handleDrop(event) {
      this.isDragActive = false
      const file = event.dataTransfer.files?.[0]
      if (file) {
        this.processFile(file)
      }
    },
    processFile(file) {
      this.error = ''
      this.success = ''

      if (!file.type.startsWith('image/')) {
        this.error = 'Por favor, selecione uma imagem válida.'
        return
      }

      if (file.size > this.maxFileSize) {
        this.error = `A imagem deve ter no máximo ${this.formatFileSize(this.maxFileSize)}.`
        return
      }

      this.selectedFile = file
      this.fileInfo = {
        name: file.name,
        size: file.size
      }

      const reader = new FileReader()
      reader.onload = (e) => {
        this.previewUrl = e.target.result
        this.$nextTick(() => {
          this.showCropModal = true
        })
      }
      reader.readAsDataURL(file)
    },
    handleCropConfirm(cropData) {
      this.previewUrl = cropData.croppedDataUrl
      this.selectedFile = null
      this.showCropModal = false
      this.$emit('update:modelValue', cropData.croppedDataUrl)
    },
    async confirmUpload() {
      if (!this.previewUrl) return

      this.uploading = true
      this.error = ''
      this.success = ''

      try {
        const { upload } = useApi()
        const formData = new FormData()

        const blob = await this.dataUrlToBlob(this.previewUrl)
        formData.append('user[profile_image]', blob, 'profile.jpg')

        const { data, error } = await upload('/api/v1/me', formData)

        if (error) {
          console.error('Erro ao salvar foto:', error)
          this.error = 'Erro ao salvar foto de perfil'
          this.$emit('upload-error', error)
          return
        }

        localStorage.setItem('user', JSON.stringify(data))
        this.$emit('update:modelValue', data.profile_image || this.previewUrl)
        this.$emit('upload-success', {
          url: data.profile_image,
          user: data
        })

        this.success = 'Foto atualizada com sucesso!'
        
        setTimeout(() => {
          this.resetUpload()
        }, 2000)
      } catch (err) {
        console.error('Erro ao fazer upload:', err)
        this.error = err.message || 'Erro ao enviar a foto.'
        this.$emit('upload-error', err)
      } finally {
        this.uploading = false
      }
    },
    removePhoto() {
      this.previewUrl = null
      this.fileInfo = null
      this.selectedFile = null
      this.$emit('update:modelValue', '')
      this.$refs.fileInput.value = ''
    },
    viewPhoto() {
      if (this.modelValue) {
        this.showLightbox = true
      }
    },
    async deletePhoto() {
      if (!confirm('Tem certeza que deseja excluir a foto de perfil?')) {
        return
      }

      this.uploading = true
      this.error = ''
      this.success = ''

      try {
        const { upload } = useApi()
        const formData = new FormData()
        formData.append('_method', 'DELETE')
        formData.append('user[profile_image]', '')

        const { data, error } = await upload('/api/v1/me', formData)

        if (error) {
          console.error('Erro ao deletar foto:', error)
          this.error = 'Erro ao deletar foto de perfil'
          return
        }

        localStorage.setItem('user', JSON.stringify(data))
        this.$emit('update:modelValue', '')
        this.$emit('upload-success', {
          url: null,
          user: data
        })

        this.success = 'Foto removida com sucesso!'
        this.previewUrl = null
        this.fileInfo = null
        
        setTimeout(() => {
          this.success = ''
        }, 3000)
      } catch (err) {
        console.error('Erro ao deletar foto:', err)
        this.error = 'Erro ao deletar foto de perfil'
      } finally {
        this.uploading = false
      }
    },
    resetUpload() {
      this.selectedFile = null
      this.fileInfo = null
      this.previewUrl = null
      this.$refs.fileInput.value = ''
    },
    async dataUrlToBlob(dataUrl) {
      const response = await fetch(dataUrl)
      return response.blob()
    },
    formatFileSize(bytes) {
      if (bytes === 0) return '0 Bytes'
      const k = 1024
      const sizes = ['Bytes', 'KB', 'MB', 'GB']
      const i = Math.floor(Math.log(bytes) / Math.log(k))
      return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i]
    }
  }
}
</script>
