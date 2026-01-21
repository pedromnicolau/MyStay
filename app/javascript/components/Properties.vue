<template>
  <CrudBase
    title="Imóveis"
    singular-title="Imóvel"
    api-endpoint="/api/v1/properties"
    :columns="columns"
    :form-fields="formFields"
  >
    <template #form="{ form, errors }">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div class="md:col-span-2">
          <label class="block text-sm font-medium text-gray-700 mb-1">Nome do Imóvel *</label>
          <input
            v-model="form.name"
            type="text"
            required
            placeholder="Ex: Casa de Praia - Balneário Camboriú"
            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">CEP</label>
          <input
            ref="zipInput"
            v-model="form.zip"
            @input="fetchAddressByCep"
            type="text"
            placeholder="00000-000"
            maxlength="9"
            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Endereço</label>
          <input
            ref="addressInput"
            v-model="form.address"
            type="text"
            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Número</label>
          <input
            v-model="form.number"
            type="text"
            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Bairro</label>
          <input
            ref="neighborhoodInput"
            v-model="form.neighborhood"
            type="text"
            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Cidade</label>
          <input
            ref="cityInput"
            v-model="form.city"
            type="text"
            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Estado</label>
          <SelectWithFilter 
            ref="stateInput"
            v-model="form.state"
            :options="stateOptions"
          />
        </div>

        <!-- Características principais -->
        <div class="md:col-span-2 grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Quartos</label>
            <input
              v-model.number="form.bedrooms"
              type="number"
              min="0"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Banheiros</label>
            <input
              v-model.number="form.bathrooms"
              type="number"
              min="0"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Hóspedes</label>
            <input
              v-model.number="form.max_guests"
              type="number"
              min="0"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>
        </div>

        <!-- Amenidades -->
        <div class="md:col-span-2">
          <label class="block text-sm font-medium text-gray-700 mb-2">O que esse lugar oferece:</label>
          <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
            <label class="flex items-center space-x-3 p-3 border border-gray-200 rounded-lg hover:border-indigo-300 hover:bg-indigo-50 transition">
              <input v-model="form.air_conditioning" type="checkbox" class="w-4 h-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500" />
              <span class="text-sm text-gray-800">Ar-condicionado</span>
            </label>
            <label class="flex items-center space-x-3 p-3 border border-gray-200 rounded-lg hover:border-indigo-300 hover:bg-indigo-50 transition">
              <input v-model="form.wifi" type="checkbox" class="w-4 h-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500" />
              <span class="text-sm text-gray-800">Wi‑Fi</span>
            </label>
            <label class="flex items-center space-x-3 p-3 border border-gray-200 rounded-lg hover:border-indigo-300 hover:bg-indigo-50 transition">
              <input v-model="form.tv" type="checkbox" class="w-4 h-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500" />
              <span class="text-sm text-gray-800">TV</span>
            </label>
            <label class="flex items-center space-x-3 p-3 border border-gray-200 rounded-lg hover:border-indigo-300 hover:bg-indigo-50 transition">
              <input v-model="form.kitchen" type="checkbox" class="w-4 h-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500" />
              <span class="text-sm text-gray-800">Cozinha</span>
            </label>
            <label class="flex items-center space-x-3 p-3 border border-gray-200 rounded-lg hover:border-indigo-300 hover:bg-indigo-50 transition">
              <input v-model="form.parking_included" type="checkbox" class="w-4 h-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500" />
              <span class="text-sm text-gray-800">Estacionamento incluído</span>
            </label>
            <label class="flex items-center space-x-3 p-3 border border-gray-200 rounded-lg hover:border-indigo-300 hover:bg-indigo-50 transition">
              <input v-model="form.washing_machine" type="checkbox" class="w-4 h-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500" />
              <span class="text-sm text-gray-800">Máquina de lavar</span>
            </label>
            <label class="flex items-center space-x-3 p-3 border border-gray-200 rounded-lg hover:border-indigo-300 hover:bg-indigo-50 transition">
              <input v-model="form.pool" type="checkbox" class="w-4 h-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500" />
              <span class="text-sm text-gray-800">Piscina</span>
            </label>
            <label class="flex items-center space-x-3 p-3 border border-gray-200 rounded-lg hover:border-indigo-300 hover:bg-indigo-50 transition">
              <input v-model="form.barbecue_grill" type="checkbox" class="w-4 h-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500" />
              <span class="text-sm text-gray-800">Churrasqueira</span>
            </label>
            <label class="flex items-center space-x-3 p-3 border border-gray-200 rounded-lg hover:border-indigo-300 hover:bg-indigo-50 transition">
              <input v-model="form.balcony" type="checkbox" class="w-4 h-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500" />
              <span class="text-sm text-gray-800">Sacada/Varanda</span>
            </label>
            <label class="flex items-center space-x-3 p-3 border border-gray-200 rounded-lg hover:border-indigo-300 hover:bg-indigo-50 transition">
              <input v-model="form.pet_friendly" type="checkbox" class="w-4 h-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500" />
              <span class="text-sm text-gray-800">Pet friendly</span>
            </label>
            <label class="flex items-center space-x-3 p-3 border border-gray-200 rounded-lg hover:border-indigo-300 hover:bg-indigo-50 transition">
              <input v-model="form.wheelchair_accessible" type="checkbox" class="w-4 h-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500" />
              <span class="text-sm text-gray-800">Acessível para cadeirantes</span>
            </label>
          </div>
        </div>

        <div class="md:col-span-2">
          <label class="block text-sm font-medium text-gray-700 mb-1">Descrição</label>
          <textarea
            v-model="form.description"
            placeholder="Descreva o imóvel com detalhes... (ex: Casa confortável à beira-mar, com vista para o oceano, 3 quartos...)"
            rows="4"
            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 resize-none"
          />
        </div>

        <div class="md:col-span-2">
          <label class="flex items-center p-4 border border-gray-200 rounded-lg hover:border-indigo-400 hover:bg-indigo-50 transition cursor-pointer group">
            <input
              v-model="form.active"
              type="checkbox"
              class="w-5 h-5 text-indigo-600 border-2 border-gray-300 rounded focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 cursor-pointer group-hover:border-indigo-500"
            />
            <div class="ml-3">
              <span class="text-sm font-semibold text-gray-700 block">Imóvel ativo</span>
              <span class="text-xs text-gray-500">{{ form.active ? 'Visível para reservas' : 'Oculto do catálogo' }}</span>
            </div>
          </label>
        </div>

        <div class="md:col-span-2">
          <label class="block text-sm font-medium text-gray-700 mb-2">Anexos (imagens e vídeos)</label>
          <div class="space-y-3">
            <div v-if="existingAttachments(form).length || newAttachments(form).length" class="flex flex-wrap gap-1">
              <!-- Attachments existentes -->
              <template v-for="(attachment, existingIdx) in existingAttachments(form)" :key="`existing-${attachment.id}`">
                <!-- Attachment -->
                <div
                  draggable="true"
                  @dragstart="startDragAttachment($event, 'existing', existingIdx, form)"
                  @dragover.prevent="dragOverAttachment($event, 'existing', existingIdx)"
                  @drop.prevent="dropAttachment($event, 'existing', existingIdx, form)"
                  @dragleave="dragOverIdx = null"
                  @dragend="endDragAttachment"
                  class="relative w-28 h-28 rounded-lg overflow-hidden border-2 bg-gray-50 cursor-move transition"
                  :class="{ 
                    'opacity-50 bg-indigo-100 border-indigo-400': draggedAttachment.from === 'existing' && draggedAttachment.fromIdx === existingIdx,
                    'border-indigo-500 ring-2 ring-indigo-300': dragOverType === 'existing' && dragOverIdx === existingIdx,
                    'border-purple-500 ring-2 ring-purple-300': existingIdx === 0,
                    'border-gray-200': existingIdx !== 0
                  }"
                  @click="openLightbox(existingIdx, form)"
                >
                  <button
                    type="button"
                    @click.stop="removeExistingAttachment(form, attachment)"
                    class="absolute top-1 right-1 bg-black bg-opacity-50 text-white rounded-full w-6 h-6 flex items-center justify-center text-xs z-10 cursor-pointer"
                    draggable="false"
                  >
                    ×
                  </button>
                  <template v-if="isImageAttachment(attachment)">
                    <img :src="attachmentPreview(attachment)" alt="Pré-visualização" class="w-full h-full object-cover pointer-events-none" />
                  </template>
                  <template v-else>
                    <video :src="attachmentPreview(attachment)" class="w-full h-full object-cover pointer-events-none" muted loop></video>
                    <span class="absolute bottom-1 left-1 text-[10px] bg-black bg-opacity-60 text-white px-1 rounded">Vídeo</span>
                  </template>
                </div>

                <!-- Drop zone depois do attachment -->
                <div
                  @dragover.prevent="dragOverDropZone($event, 'existing', existingIdx, 'after')"
                  @drop.prevent="dropInZone($event, 'existing', existingIdx, 'after', form)"
                  @dragleave="clearDropZone"
                  class="w-3 h-28 transition-all"
                  :class="dropZoneActive === `existing-${existingIdx}-after` ? 'bg-indigo-400 w-6 rounded-lg' : 'bg-transparent'"
                ></div>
              </template>

              <!-- Attachments novos -->
              <template v-for="(file, newIdx) in newAttachments(form)" :key="`new-${file.name}-${file.lastModified}`">
                <!-- Attachment -->
                <div
                  draggable="true"
                  @dragstart="startDragAttachment($event, 'new', newIdx, form)"
                  @dragover.prevent="dragOverAttachment($event, 'new', newIdx)"
                  @drop.prevent="dropAttachment($event, 'new', newIdx, form)"
                  @dragleave="dragOverIdx = null"
                  @dragend="endDragAttachment"
                  class="relative w-28 h-28 rounded-lg overflow-hidden border-2 border-indigo-200 bg-indigo-50 cursor-move transition"
                  :class="{ 
                    'opacity-50 bg-indigo-100 border-indigo-600': draggedAttachment.from === 'new' && draggedAttachment.fromIdx === newIdx,
                    'border-indigo-500 ring-2 ring-indigo-300': dragOverType === 'new' && dragOverIdx === newIdx
                  }"
                  @click="openLightbox(existingAttachments(form).length + newIdx, form)"
                >
                  <button
                    type="button"
                    @click.stop="removeNewAttachment(form, file)"
                    class="absolute top-1 right-1 bg-indigo-600 text-white rounded-full w-6 h-6 flex items-center justify-center text-xs z-10 cursor-pointer"
                    draggable="false"
                  >
                    ×
                  </button>
                  <template v-if="isImageAttachment(file)">
                    <img :src="attachmentPreview(file)" alt="Pré-visualização" class="w-full h-full object-cover pointer-events-none" />
                  </template>
                  <template v-else>
                    <video :src="attachmentPreview(file)" class="w-full h-full object-cover pointer-events-none" muted loop></video>
                    <span class="absolute bottom-1 left-1 text-[10px] bg-indigo-600 text-white px-1 rounded">Novo</span>
                  </template>
                </div>

                <!-- Drop zone depois do attachment -->
                <div
                  @dragover.prevent="dragOverDropZone($event, 'new', newIdx, 'after')"
                  @drop.prevent="dropInZone($event, 'new', newIdx, 'after', form)"
                  @dragleave="clearDropZone"
                  class="w-3 h-28 transition-all"
                  :class="dropZoneActive === `new-${newIdx}-after` ? 'bg-indigo-400 w-6 rounded-lg' : 'bg-transparent'"
                ></div>
              </template>
            </div>

            <label
              class="flex items-center justify-center w-full px-4 py-3 border-2 border-dashed border-gray-300 rounded-lg text-sm text-gray-600 hover:border-indigo-400 hover:text-indigo-600 cursor-pointer bg-gray-50"
              @dragenter.prevent
              @dragover.prevent
              @drop.prevent="handleDrop($event, form)"
            >
              <input
                type="file"
                accept="image/*,video/*"
                class="hidden"
                multiple
                @change="handleAttachmentsSelected($event, form)"
              />
              <div class="flex items-center space-x-2">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                </svg>
                <span>Adicionar anexos</span>
              </div>
            </label>
          </div>
        </div>

      </div>
    </template>
  </CrudBase>

  <div
    v-if="lightbox.open"
    class="fixed inset-0 z-[60] bg-black bg-opacity-80 flex items-center justify-center p-4"
    @click.self="closeLightbox"
  >
    <button
      class="absolute top-4 right-4 text-white bg-black bg-opacity-50 hover:bg-opacity-70 rounded-full w-10 h-10 flex items-center justify-center"
      @click="closeLightbox"
      aria-label="Fechar"
    >
      ×
    </button>

    <button
      class="absolute left-4 text-white bg-black bg-opacity-50 hover:bg-opacity-70 rounded-full w-10 h-10 flex items-center justify-center"
      @click="prevLightbox"
      aria-label="Anterior"
    >
      ‹
    </button>

    <button
      class="absolute right-4 text-white bg-black bg-opacity-50 hover:bg-opacity-70 rounded-full w-10 h-10 flex items-center justify-center"
      @click="nextLightbox"
      aria-label="Próximo"
    >
      ›
    </button>

    <div class="max-w-5xl w-full max-h-[90vh] bg-gray-900 rounded-xl overflow-hidden shadow-2xl border border-gray-800 flex flex-col">
      <div class="p-4 text-gray-100 text-sm flex items-center justify-between bg-gray-800 gap-3 flex-wrap">
        <div class="flex items-center gap-2">
          <span class="font-medium">{{ currentFilename() }}</span>
          <span class="text-gray-400">{{ lightbox.index + 1 }} / {{ lightbox.items.length }}</span>
        </div>
        <div class="flex items-center gap-2">
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
        </div>
      </div>
      <div class="flex-1 flex items-center justify-center bg-gray-950 p-4 overflow-auto">
        <template v-if="isImageAttachment(currentLightboxItem())">
          <img
            :src="currentPreviewUrl()"
            class="max-h-[75vh] max-w-full object-contain select-none cursor-grab"
            :class="{ 'cursor-grabbing': lightbox.isDragging }"
            :style="{ transform: `translate(${lightbox.panX}px, ${lightbox.panY}px) scale(${lightbox.zoom})` }"
            @mousedown="startDrag"
            @mousemove="onDrag"
            @mouseup="stopDrag"
            @mouseleave="stopDrag"
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
import axios from 'axios'
import CrudBase from './CrudBase.vue'
import SelectWithFilter from './SelectWithFilter.vue'
import { BRAZILIAN_STATES } from '../constants/brazilianStates.js'
import { useViaCep } from '../composables/useViaCep.js'

const { handleCepLookup } = useViaCep()

export default {
  components: {
    CrudBase,
    SelectWithFilter
  },

  data() {
    return {
      stateOptions: BRAZILIAN_STATES,
      draggedAttachment: {
        from: null,
        fromIdx: null
      },
      dragOverIdx: null,
      dragOverType: null,
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
      },
      columns: [
        { key: 'name', label: 'Nome' },
        { key: 'city', label: 'Cidade',
          format: (value, item) => item.state ? `${value} - ${item.state}` : value
        },
        { key: 'state', label: 'Estado' },
        { key: 'neighborhood', label: 'Bairro' },
        { key: 'bedrooms', label: 'Quartos', format: (v) => v ?? 0 },
        { key: 'bathrooms', label: 'Banheiros', format: (v) => v ?? 0 },
        { key: 'max_guests', label: 'Hóspedes', format: (v) => v ?? 0 },
        { 
          key: 'active', 
          label: 'Status',
          format: (value) => value ? 'Ativo' : 'Inativo'
        }
      ],
      formFields: {
        name: '',
        description: '',
        address: '',
        number: '',
        neighborhood: '',
        zip: '',
        city: '',
        state: '',
        main_attachment_id: null,
        main_attachment_name: '',
        bedrooms: 0,
        bathrooms: 0,
        max_guests: 0,
        air_conditioning: false,
        wifi: false,
        tv: false,
        kitchen: false,
        parking_included: false,
        washing_machine: false,
        pool: false,
        barbecue_grill: false,
        balcony: false,
        pet_friendly: false,
        wheelchair_accessible: false,
        attachments: [],
        attachments_order: [],
        remove_attachment_ids: [],
        active: true
      }
    }
  },

  watch: {
    'form.attachments': {
      handler(newAttachments) {
        if (!Array.isArray(newAttachments)) return
        
        // Atualizar attachments_order com IDs dos anexos existentes
        // Nota: Mantemos a ordem atual de attachments_order se for válida
        const existingAttachmentIds = newAttachments
          .filter(att => att && att.id && !this.isFileAttachment(att))
          .map(att => att.id)

        // Se não temos uma ordem salva, criar uma baseada na ordem atual
        if (!this.form.attachments_order || !this.form.attachments_order.length) {
          this.form.attachments_order = existingAttachmentIds
        }
        
        // Sincronizar anexo principal (primeiro é sempre o principal)
        this.$nextTick(() => {
          this.syncMainAttachmentId()
        })
      },
      deep: true
    }
  },

  methods: {
    editItem(item) {
      this.$parent.editItem(item)
      this.$nextTick(() => {
        this.syncMainAttachmentId()
        this.syncAttachmentsOrder()
      })
    },

    syncMainAttachmentId() {
      if (!Array.isArray(this.form.attachments)) return
      
      // O primeiro anexo existente é sempre o principal
      const firstExisting = this.form.attachments.find(att => att && att.id && !this.isFileAttachment(att))
      if (firstExisting && firstExisting.id) {
        this.form.main_attachment_id = firstExisting.id
        this.form.main_attachment_name = ''
      } else {
        // Se não há anexos existentes, verificar se há novos
        const firstNew = this.form.attachments.find(att => this.isFileAttachment(att))
        if (firstNew) {
          this.form.main_attachment_id = null
          this.form.main_attachment_name = firstNew.name
        }
      }
    },

    isFileAttachment(item) {
      return (typeof File !== 'undefined' && item instanceof File) ||
        (typeof Blob !== 'undefined' && item instanceof Blob)
    },

    syncAttachmentsOrder() {
      // Sincronizar attachments_order quando o modal é aberto
      if (!Array.isArray(this.form.attachments)) return
      
      const existingIds = this.form.attachments
        .filter(att => att && att.id && !this.isFileAttachment(att))
        .map(att => att.id)
      
      // Se não temos uma ordem salva, usar a ordem atual
      if (!this.form.attachments_order || !this.form.attachments_order.length) {
        this.form.attachments_order = existingIds
      }
    },

    fetchAddressByCep(event) {
      handleCepLookup(event, this.$refs, this.form)
    },

    handleAttachmentsSelected(event, form) {
      this.attachFiles(event.target.files, form)

      // Permite selecionar o mesmo arquivo novamente
      event.target.value = ''
    },

    handleDrop(event, form) {
      const files = event.dataTransfer?.files
      if (!files || !files.length) return
      this.attachFiles(files, form)
    },

    attachFiles(fileList, form) {
      const selectedFiles = Array.from(fileList || [])
        .filter(file => this.isAllowedFile(file))
        .map(file => this.decorateFileWithPreview(file))
      const current = Array.isArray(form.attachments) ? form.attachments : []
      form.attachments = [ ...current, ...selectedFiles ]
      
      // Sincronizar anexo principal após adicionar novos arquivos
      this.$nextTick(() => {
        this.syncMainAttachmentId()
      })
    },

    isAllowedFile(file) {
      const type = (file?.type || '').toLowerCase()
      if (type.startsWith('image/') || type.startsWith('video/')) return true
      const name = (file?.name || '').toLowerCase()
      return /\.(png|jpe?g|gif|webp|bmp|avif|heic|heif|mp4|mov|webm|ogg|mkv|avi|m4v)$/i.test(name)
    },

    removeExistingAttachment(form, attachment) {
      if (!Array.isArray(form.remove_attachment_ids)) {
        form.remove_attachment_ids = []
      }

      if (attachment.id && !form.remove_attachment_ids.includes(attachment.id)) {
        form.remove_attachment_ids.push(attachment.id)
      }

      form.attachments = (form.attachments || []).filter(item => item.id !== attachment.id)
      
      // Atualizar o anexo principal após remoção
      this.$nextTick(() => {
        this.syncMainAttachmentId()
      })
    },

    removeNewAttachment(form, file) {
      if (file.previewUrl) {
        URL.revokeObjectURL(file.previewUrl)
      }

      form.attachments = (form.attachments || []).filter(item => item !== file)
      
      // Atualizar o anexo principal após remoção
      this.$nextTick(() => {
        this.syncMainAttachmentId()
      })
    },

    existingAttachments(form) {
      const items = (form.attachments || [])
        .filter(item => !this.isFileAttachment(item))
      
      // Aplicar ordenação salva se disponível
      const order = form.attachments_order || []
      const orderMap = new Map(order.map((id, idx) => [id, idx]))
      
      // Ordenar pela ordem salva
      items.sort((a, b) => {
        const aPos = orderMap.has(a.id) ? orderMap.get(a.id) : Infinity
        const bPos = orderMap.has(b.id) ? orderMap.get(b.id) : Infinity
        return aPos - bPos
      })
      
      return items
    },

    newAttachments(form) {
      return (form.attachments || [])
        .filter(item => this.isFileAttachment(item))
    },

    startDragAttachment(event, type, index, form) {
      this.draggedAttachment.from = type
      this.draggedAttachment.fromIdx = index
      event.dataTransfer.effectAllowed = 'move'
    },

    dragOverAttachment(event, type, index) {
      event.dataTransfer.dropEffect = 'move'
      this.dragOverType = type
      this.dragOverIdx = index
    },

    dropAttachment(event, toType, toIdx, form) {
      const fromType = this.draggedAttachment.from
      const fromIdx = this.draggedAttachment.fromIdx

      if (fromType === null || fromIdx === null) return
      if (fromType === toType && fromIdx === toIdx) return

      // Trabalhar diretamente com form.attachments
      const allAttachments = form.attachments || []
      
      // Encontrar índices reais em form.attachments
      const existing = this.existingAttachments(form)
      const newFiles = this.newAttachments(form)
      
      // Obter o item que será movido
      let draggedItem = null
      if (fromType === 'existing') {
        draggedItem = existing[fromIdx]
      } else {
        draggedItem = newFiles[fromIdx]
      }

      if (!draggedItem) return

      // Encontrar índice real do item em form.attachments
      const fromRealIdx = allAttachments.indexOf(draggedItem)
      if (fromRealIdx === -1) return

      // Obter o item de destino para encontrar seu índice real
      let targetItem = null
      if (toType === 'existing') {
        targetItem = existing[toIdx]
      } else {
        targetItem = newFiles[toIdx]
      }

      const toRealIdx = targetItem ? allAttachments.indexOf(targetItem) : allAttachments.length

      // SWAP: Trocar posições dos dois anexos
      const temp = allAttachments[fromRealIdx]
      allAttachments[fromRealIdx] = allAttachments[toRealIdx]
      allAttachments[toRealIdx] = temp

      // Forçar reatividade
      form.attachments = [...allAttachments]

      // Atualizar attachments_order com a nova ordem
      this.updateAttachmentsOrder(form)
      
      // Sincronizar anexo principal (primeiro é sempre o principal)
      this.$nextTick(() => {
        this.syncMainAttachmentId()
      })

      // Salvar a ordem dos anexos se o property foi criado
      this.saveAttachmentsOrder(form)

      this.draggedAttachment.from = null
      this.draggedAttachment.fromIdx = null
      this.dragOverType = null
      this.dragOverIdx = null
    },

    endDragAttachment() {
      this.draggedAttachment.from = null
      this.draggedAttachment.fromIdx = null
      this.dropZoneActive = null
    },

    dragOverDropZone(event, type, index, position) {
      event.dataTransfer.dropEffect = 'move'
      this.dropZoneActive = `${type}-${index}-${position}`
    },

    clearDropZone() {
      this.dropZoneActive = null
    },

    updateAttachmentsOrder(form) {
      // Atualizar attachments_order com os IDs dos anexos existentes na ordem atual
      const allAttachments = form.attachments || []
      const attachmentIds = allAttachments
        .filter(att => att && att.id)
        .map(att => att.id)
      
      form.attachments_order = attachmentIds
    },

    dropInZone(event, toType, toIdx, position, form) {
      const fromType = this.draggedAttachment.from
      const fromIdx = this.draggedAttachment.fromIdx

      if (fromType === null || fromIdx === null) return

      // Sempre inserir após o anexo (position sempre será 'after')
      const targetIdx = toIdx + 1

      // Trabalhar diretamente com form.attachments
      const allAttachments = form.attachments || []
      
      // Encontrar índices reais em form.attachments
      const existing = this.existingAttachments(form)
      const newFiles = this.newAttachments(form)
      
      // Obter o item que será movido
      let draggedItem = null
      if (fromType === 'existing') {
        draggedItem = existing[fromIdx]
      } else {
        draggedItem = newFiles[fromIdx]
      }

      if (!draggedItem) return

      // Encontrar índice real do item em form.attachments
      const fromRealIdx = allAttachments.indexOf(draggedItem)
      if (fromRealIdx === -1) return

      // Encontrar o índice real de inserção
      let toRealIdx = 0
      if (toType === 'existing' && targetIdx < existing.length) {
        toRealIdx = allAttachments.indexOf(existing[targetIdx])
      } else if (toType === 'new' && targetIdx < newFiles.length) {
        toRealIdx = allAttachments.indexOf(newFiles[targetIdx])
      } else {
        // Inserir no final
        toRealIdx = allAttachments.length
      }

      // Remover do índice antigo
      const [removed] = allAttachments.splice(fromRealIdx, 1)
      
      // Ajustar índice se necessário
      const insertIdx = fromRealIdx < toRealIdx ? toRealIdx - 1 : toRealIdx
      allAttachments.splice(insertIdx, 0, removed)

      // Forçar reatividade
      form.attachments = [...allAttachments]

      // Atualizar attachments_order com a nova ordem
      this.updateAttachmentsOrder(form)
      
      // Sincronizar anexo principal (primeiro é sempre o principal)
      this.$nextTick(() => {
        this.syncMainAttachmentId()
      })

      // Salvar a ordem dos anexos se o property foi criado
      this.saveAttachmentsOrder(form)

      this.draggedAttachment.from = null
      this.draggedAttachment.fromIdx = null
      this.dropZoneActive = null
    },

    async saveAttachmentsOrder(form) {
      // Só salvar se houver um ID de property (item já salvo no banco)
      if (!this.$parent.editingItem || !this.$parent.editingItem.id) return

      try {
        // Usar a ordem salva em attachments_order que foi atualizada pelo updateAttachmentsOrder
        const attachmentIds = form.attachments_order || []
        
        if (!attachmentIds.length) return

        const payload = {
          property: {
            attachments_order: attachmentIds
          }
        }

        const token = localStorage.getItem('token')
        await axios.put(
          `/api/v1/properties/${this.$parent.editingItem.id}`,
          payload,
          { headers: { Authorization: `Bearer ${token}` } }
        )
      } catch (error) {
        console.error('Erro ao salvar ordem dos anexos:', error)
      }
    },

    attachmentContentType(attachment) {
      if (!attachment) return ''
      return attachment.content_type || attachment.type || ''
    },

    isImageAttachment(attachment) {
      const contentType = this.attachmentContentType(attachment)
      if (contentType) return contentType.startsWith('image/')
      const url = this.attachmentPreview(attachment)
      return typeof url === 'string' && url.match(/\.(png|jpe?g|gif|webp|bmp|avif)(\?|$)/i)
    },

    isVideoAttachment(attachment) {
      const contentType = this.attachmentContentType(attachment)
      if (contentType) return contentType.startsWith('video/')
      const url = this.attachmentPreview(attachment)
      return typeof url === 'string' && url.match(/\.(mp4|mov|webm|ogg|mkv)(\?|$)/i)
    },

    attachmentPreview(attachment) {
      if (this.isFileAttachment(attachment)) {
        if (!attachment.previewUrl) {
          attachment.previewUrl = URL.createObjectURL(attachment)
        }
        return attachment.previewUrl
      }

      return attachment.url || attachment.previewUrl || ''
    },

    decorateFileWithPreview(file) {
      if (!file.previewUrl) {
        file.previewUrl = URL.createObjectURL(file)
      }
      return file
    },

    allAttachments(form) {
      return [ ...this.existingAttachments(form), ...this.newAttachments(form) ]
    },

    ensurePreview(item) {
      if (this.isFileAttachment(item) && !item.previewUrl) {
        item.previewUrl = URL.createObjectURL(item)
      }
      return item
    },

    openLightbox(index, form) {
      const items = this.allAttachments(form).map(item => this.ensurePreview(item))
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
      return this.lightbox.items[this.lightbox.index] || null
    },

    currentPreviewUrl() {
      const item = this.currentLightboxItem()
      return item ? this.attachmentPreview(item) : ''
    },

    currentFilename() {
      const item = this.currentLightboxItem()
      return item?.filename || item?.name || 'arquivo'
    },

    canZoom() {
      const item = this.currentLightboxItem()
      return item ? this.isImageAttachment(item) : false
    },

    zoomIn() {
      if (!this.canZoom()) return
      this.lightbox.zoom = Math.min(this.lightbox.zoom + 0.25, 4)
    },

    zoomOut() {
      if (!this.canZoom()) return
      this.lightbox.zoom = Math.max(this.lightbox.zoom - 0.25, 0.25)
      if (this.lightbox.zoom === 1) {
        this.lightbox.panX = 0
        this.lightbox.panY = 0
      }
    },

    resetZoom() {
      this.lightbox.zoom = 1
      this.lightbox.panX = 0
      this.lightbox.panY = 0
    },

    startDrag(event) {
      this.lightbox.isDragging = true
      this.lightbox.dragStartX = event.clientX - this.lightbox.panX
      this.lightbox.dragStartY = event.clientY - this.lightbox.panY
      event.preventDefault()
    },

    onDrag(event) {
      if (!this.lightbox.isDragging) return
      this.lightbox.panX = event.clientX - this.lightbox.dragStartX
      this.lightbox.panY = event.clientY - this.lightbox.dragStartY
    },

    stopDrag() {
      this.lightbox.isDragging = false
    },

    handleWheel(event) {
      if (!this.canZoom()) return
      event.preventDefault()
      
      const delta = event.deltaY
      const zoomSpeed = 0.1
      
      if (delta < 0) {
        // Scroll up - zoom in
        this.lightbox.zoom = Math.min(this.lightbox.zoom + zoomSpeed, 4)
      } else {
        // Scroll down - zoom out
        this.lightbox.zoom = Math.max(this.lightbox.zoom - zoomSpeed, 0.25)
        if (this.lightbox.zoom === 1) {
          this.lightbox.panX = 0
          this.lightbox.panY = 0
        }
      }
    }
  }
}
</script>
