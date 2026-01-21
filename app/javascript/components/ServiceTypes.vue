<template>
  <CrudBase
    title="Tipos de Serviço"
    singular-title="Tipo de Serviço"
    api-endpoint="/api/v1/service_types"
    :columns="columns"
    :form-fields="formFields"
  >
    <template #form="{ form, errors }">
      <div class="space-y-4">
        <div>
          <label for="name" class="block text-sm font-medium text-gray-700 mb-1">
            Nome <span class="text-red-500">*</span>
          </label>
          <input
            v-model="form.name"
            id="name"
            type="text"
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
            :class="{ 'border-red-500': errors.name }"
            required
          />
          <span v-if="errors.name" class="text-red-500 text-sm">{{ errors.name }}</span>
        </div>
      </div>
    </template>
  </CrudBase>
</template>

<script>
import CrudBase from './CrudBase.vue'

export default {
  components: {
    CrudBase
  },

  data() {
    return {
      columns: [
        { key: 'name', label: 'Nome' }
      ],
      formFields: {
        name: ''
      }
    }
  }
}
</script>
