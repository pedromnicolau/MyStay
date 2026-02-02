<template>
  <div class="space-y-6">
    <!-- Seção de Foto de Perfil -->
    <div class="border-b border-gray-200 pb-6">
      <h3 class="text-lg font-semibold text-gray-900 mb-4">Foto de Perfil</h3>
      <ProfilePhotoUpload 
        v-model="form.profile_image"
        :name="form.name"
        @upload-success="handlePhotoUploadSuccess"
        @upload-error="handlePhotoUploadError"
      />
    </div>

    <!-- Seção de Informações Pessoais -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Nome *</label>
        <input
          v-model="form.name"
          type="text"
          required
          class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
        />
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">E-mail</label>
        <input
          v-model="form.email"
          type="email"
          class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
        />
      </div>

      <div>
        <div class="flex items-center justify-between mb-1">
          <label class="block text-sm font-medium text-gray-700">Telefone *</label>
          <a
            v-if="phoneWhatsAppLink(form.phone)"
            :href="phoneWhatsAppLink(form.phone)"
            target="_blank"
            rel="noopener"
            class="text-gray-400 hover:text-emerald-600 transition"
            title="Abrir no WhatsApp"
          >
            <i class="fab fa-whatsapp text-lg"></i>
          </a>
        </div>
        <input
          v-model="form.phone"
          @input="applyPhoneMask"
          type="tel"
          required
          placeholder="(00) 00000-0000"
          maxlength="15"
          class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
        />
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">CPF *</label>
        <input
          v-model="form.cpf"
          @input="applyCpfMask"
          type="text"
          required
          placeholder="000.000.000-00"
          maxlength="14"
          class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
        />
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">RG</label>
        <input
          v-model="form.rg"
          @input="applyRgMask"
          type="text"
          maxlength="12"
          class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
        />
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Profissão</label>
        <input
          v-model="form.profession"
          type="text"
          class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
        />
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Estado Civil</label>
        <select
          v-model="form.marital_status"
          class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
        >
          <option value="">Selecione</option>
          <option value="Solteiro(a)">Solteiro(a)</option>
          <option value="Casado(a)">Casado(a)</option>
          <option value="Divorciado(a)">Divorciado(a)</option>
          <option value="Viúvo(a)">Viúvo(a)</option>
        </select>
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

      <div class="md:col-span-2">
        <label class="block text-sm font-medium text-gray-700 mb-2">Perfis *</label>
        <div class="grid grid-cols-1 sm:grid-cols-3 gap-3">
          <label class="flex items-center space-x-2 p-3 border border-gray-200 rounded-lg hover:border-indigo-300 transition cursor-pointer">
            <input v-model="form.customer" type="checkbox" class="w-4 h-4 text-indigo-600 border-gray-300 rounded focus:ring-2 focus:ring-indigo-500" />
            <span class="text-sm font-medium text-gray-700">Cliente</span>
          </label>
          <label class="flex items-center space-x-2 p-3 border border-gray-200 rounded-lg hover:border-indigo-300 transition cursor-pointer">
            <input v-model="form.agent" type="checkbox" class="w-4 h-4 text-indigo-600 border-gray-300 rounded focus:ring-2 focus:ring-indigo-500" />
            <span class="text-sm font-medium text-gray-700">Corretor</span>
          </label>
          <label class="flex items-center space-x-2 p-3 border border-gray-200 rounded-lg hover:border-indigo-300 transition cursor-pointer">
            <input v-model="form.provider" type="checkbox" class="w-4 h-4 text-indigo-600 border-gray-300 rounded focus:ring-2 focus:ring-indigo-500" />
            <span class="text-sm font-medium text-gray-700">Prestador</span>
          </label>
        </div>
      </div>

      <div class="md:col-span-2">
        <label class="block text-sm font-medium text-gray-700 mb-1">Observações</label>
        <textarea
          v-model="form.note"
          rows="3"
          class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
        ></textarea>
      </div>

      <div class="md:col-span-2">
        <label class="flex items-center space-x-3 p-4 border-2 border-gray-200 rounded-lg hover:border-indigo-300 transition cursor-pointer group">
          <input
            v-model="form.blocked"
            type="checkbox"
            class="w-5 h-5 text-red-600 border-gray-300 rounded focus:ring-2 focus:ring-red-500 cursor-pointer"
          />
          <div class="flex-1">
            <span class="text-sm font-semibold text-gray-900">{{ blockLabel }}</span>
            <p class="text-xs text-gray-500 mt-0.5">Esta pessoa não poderá ser selecionada em novas operações</p>
          </div>
          <svg class="w-5 h-5 text-red-500 opacity-0 group-hover:opacity-100 transition" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
          </svg>
        </label>
      </div>
    </div>
  </div>
</template>

<script>
import SelectWithFilter from './SelectWithFilter.vue'
import ProfilePhotoUpload from './ProfilePhotoUpload.vue'
import { BRAZILIAN_STATES } from '../constants/brazilianStates.js'
import { useBrazilianMasks } from '../composables/useBrazilianMasks.js'
import { useViaCep } from '../composables/useViaCep.js'

const { getWhatsAppLink, handlePhoneInput, handleCpfInput, handleRgInput } = useBrazilianMasks()
const { handleCepLookup } = useViaCep()

export default {
  components: {
    SelectWithFilter,
    ProfilePhotoUpload
  },

  props: {
    form: {
      type: Object,
      required: true
    },
    blockLabel: {
      type: String,
      required: true
    }
  },

  data() {
    return {
      stateOptions: BRAZILIAN_STATES
    }
  },

  methods: {
    fetchAddressByCep(event) {
      handleCepLookup(event, this.$refs, this.form)
    },

    applyPhoneMask(event) {
      handlePhoneInput(event, this.form)
    },

    applyCpfMask(event) {
      handleCpfInput(event, this.form)
    },

    handlePhotoUploadSuccess(payload) {
      // A foto foi processada, agora será salva junto com o formulário
      console.log('Foto preparada para salvar:', payload)
      this.$emit('photo-uploaded', payload)
    },

    handlePhotoUploadError(error) {
      console.error('Erro ao fazer upload da foto:', error)
      this.$emit('photo-error', error)
    },

    applyRgMask(event) {
      handleRgInput(event, this.form)
    },

    phoneWhatsAppLink(phone) {
      return getWhatsAppLink(phone)
    }
  }
}
</script>
