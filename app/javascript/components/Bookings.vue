<template>
  <div class="min-h-screen bg-gray-50">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div class="mb-6 flex justify-between items-center">
        <h1 class="text-3xl font-bold text-gray-900">Locações</h1>
        <div class="flex items-center space-x-3">
          <button
            @click="openCreateModal('booking')"
            :disabled="properties.length === 0"
            :class="[
              'px-6 py-2.5 rounded-lg transition flex items-center space-x-2 shadow-sm',
              properties.length === 0 
                ? 'bg-gray-300 text-gray-500 cursor-not-allowed' 
                : 'bg-indigo-600 text-white hover:bg-indigo-700'
            ]"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
            </svg>
            <span>Nova Locação</span>
          </button>

          <button
            @click="openCreateModal('cleaning')"
            :disabled="properties.length === 0"
            :class="[
              'px-6 py-2.5 rounded-lg transition flex items-center space-x-2 shadow-sm',
              properties.length === 0 
                ? 'bg-gray-300 text-gray-500 cursor-not-allowed' 
                : 'bg-emerald-600 text-white hover:bg-emerald-700'
            ]"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
            </svg>
            <span>Novo Serviço</span>
          </button>
        </div>
      </div>

      <!-- Estado vazio: Sem imóveis cadastrados -->
      <div v-if="properties.length === 0" class="bg-white rounded-lg shadow-sm p-12">
        <div class="max-w-md mx-auto text-center">
          <div class="inline-flex items-center justify-center w-16 h-16 bg-indigo-100 rounded-full mb-4">
            <svg class="w-8 h-8 text-indigo-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
            </svg>
          </div>
          <h3 class="text-xl font-semibold text-gray-900 mb-2">Nenhum imóvel cadastrado</h3>
          <p class="text-gray-600 mb-6">
            Para criar locações, é necessário cadastrar ao menos um imóvel no sistema.
          </p>
          <button
            @click="navigateToProperties"
            class="inline-flex items-center px-6 py-3 bg-indigo-600 text-white font-medium rounded-lg hover:bg-indigo-700 transition shadow-sm"
          >
            <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
            </svg>
            Cadastrar Imóvel
          </button>
        </div>
      </div>

      <!-- Calendário e filtros: Quando há imóveis -->
      <div v-else class="bg-white rounded-lg shadow-sm p-6 mb-6">
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-2">Filtrar por Imóvel</label>
          <select
            v-model.number="selectedPropertyId"
            class="w-full md:w-64 px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
          >
            <option v-for="property in properties" :key="property.id" :value="property.id">
              {{ property.name }}
            </option>
          </select>
        </div>

        <div class="flex items-center justify-between mb-4">
          <button
            @click="previousMonth"
            class="p-2 hover:bg-gray-100 rounded-lg transition"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
            </svg>
          </button>
          
          <div class="flex items-center space-x-4">
            <h2 class="text-xl font-semibold text-gray-900">
              {{ monthNames[currentMonth] }} {{ currentYear }}
            </h2>
            <button
              @click="goToToday"
              class="text-sm px-3 py-1 bg-indigo-100 text-indigo-700 rounded-md hover:bg-indigo-200 transition"
            >
              Hoje
            </button>
          </div>

          <button
            @click="nextMonth"
            class="p-2 hover:bg-gray-100 rounded-lg transition"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
            </svg>
          </button>
        </div>

        <div class="grid grid-cols-7 gap-2">
          <div
            v-for="day in weekDays"
            :key="day"
            class="text-center text-sm font-semibold text-gray-600 py-2"
          >
            {{ day }}
          </div>

          <div
            v-for="(day, index) in calendarDays"
            :key="index"
            :class="[
              'min-h-24 p-2 border border-gray-200 rounded-lg',
              day.isCurrentMonth ? 'bg-white' : 'bg-gray-50',
              day.isToday ? 'ring-2 ring-indigo-500' : ''
            ]"
          >
            <div class="flex justify-between items-start mb-1">
              <span
                :class="[
                  'text-sm font-medium',
                  day.isCurrentMonth ? 'text-gray-900' : 'text-gray-400',
                  day.isToday ? 'bg-indigo-600 text-white rounded-full w-6 h-6 flex items-center justify-center text-xs' : ''
                ]"
              >
                {{ day.date.getDate() }}
              </span>
            </div>

            <div class="space-y-1">
              <div
                v-for="booking in getBookingsForDay(day.date)"
                :key="booking.id"
                @click="viewBooking(booking)"
                :class="[
                  'text-xs p-1 rounded cursor-pointer truncate',
                  getBookingColor(booking)
                ]"
                :title="booking.guest_name + ' - ' + booking.property_name"
              >
                {{ getBookingLabel(booking) }}
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow-sm p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">Locações do Mês</h3>
        
        <div v-if="loading" class="flex justify-center py-8">
          <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600"></div>
        </div>

        <div v-else-if="bookings.length === 0" class="text-center py-8 text-gray-500">
          Nenhuma locação neste período
        </div>

        <div v-else class="space-y-3">
          <div
            v-for="booking in sortedBookings"
            :key="booking.id"
            @click="viewBooking(booking)"
            :class="[
              'p-4 rounded-lg border-l-4 cursor-pointer hover:shadow-md transition',
              booking.property_type === 'cleaning' ? 'bg-amber-50 border-amber-500' : 'bg-indigo-50 border-indigo-500'
            ]"
          >
            <div class="flex justify-between items-start">
              <div class="flex-1">
                <div class="flex items-center space-x-2 mb-1">
                  <h4 class="font-semibold text-gray-900">{{ getBookingLabel(booking) }}</h4>
                  <span
                    v-if="booking.property_type === 'cleaning'"
                    class="text-xs px-2 py-0.5 rounded-full bg-amber-200 text-amber-800"
                  >
                    Faxina
                  </span>
                </div>
                <p class="text-sm text-gray-600">{{ booking.property_name }}</p>
                <div class="flex items-center space-x-4 mt-2 text-xs text-gray-500">
                  <span>Entrada: {{ formatDate(booking.check_in_date) }}</span>
                  <span>Saída: {{ formatDate(booking.check_out_date) }}</span>
                  <span v-if="booking.total_price" class="font-semibold text-gray-900">
                    R$ {{ parseFloat(booking.total_price).toFixed(2) }}
                  </span>
                </div>
              </div>
              <div class="flex space-x-2">
                <button
                  @click.stop="editBooking(booking)"
                  class="text-indigo-600 hover:text-indigo-900"
                >
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                  </svg>
                </button>
                <button
                  @click.stop="confirmDelete(booking)"
                  class="text-red-600 hover:text-red-900"
                >
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                  </svg>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div
      v-if="isModalOpen"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
      @click.self="closeModal"
    >
      <div class="bg-white rounded-lg shadow-xl max-w-2xl w-full max-h-[90vh] flex flex-col overflow-hidden">
        <div class="px-6 py-4 border-b border-gray-200 flex justify-between items-center flex-shrink-0">
          <h2 class="text-xl font-semibold text-gray-900">
            {{ editingBooking ? (entryType === 'cleaning' ? 'Editar Serviço' : 'Editar Locação') : (entryType === 'cleaning' ? 'Novo Serviço' : 'Nova Locação') }}
          </h2>
          <button @click="closeModal" class="text-gray-400 hover:text-gray-600">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <form @submit.prevent="saveBooking" class="px-6 py-4 overflow-y-auto flex-1 flex flex-col">
          <div v-if="entryType === 'cleaning'" class="space-y-4">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <PersonSelect
                  v-model="form.customer_id"
                  :options="cleanerOptions"
                  :selected-person="selectedCleaner"
                  label="Faxineira *"
                  @update:modelValue="handleCleanerChange"
                />
              </div>

              <div>
                <ServiceTypeSelect
                  v-model="form.service_type_id"
                  :options="serviceTypeOptions"
                  label="Tipo de Serviço *"
                  @update:modelValue="handleServiceTypeChange"
                />
              </div>
            </div>

            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Data Início *</label>
                <input
                  v-model="form.check_in_date"
                  type="date"
                  required
                  class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                />
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Data Fim *</label>
                <input
                  v-model="form.check_out_date"
                  type="date"
                  required
                  class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                />
              </div>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Valor Total a Pagar (R$)</label>
              <input
                v-model.number="form.total_payable"
                type="number"
                step="0.01"
                min="0"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Observação</label>
              <textarea
                v-model="form.description"
                rows="4"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              ></textarea>
            </div>
          </div>

          <div v-else class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <PersonSelect
                v-model="form.customer_id"
                :options="customerOptions"
                :selected-person="selectedCustomer"
                label="Hóspede *"
                @update:modelValue="handleCustomerChange"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Imóvel *</label>
              <select
                v-model.number="form.property_id"
                required
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              >
                <option value="" disabled>Selecione um imóvel</option>
                <option v-for="property in properties" :key="property.id" :value="property.id">
                  {{ property.name }}
                </option>
              </select>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Check-in *</label>
              <input
                v-model="form.check_in_date"
                type="date"
                required
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Check-out *</label>
              <input
                v-model="form.check_out_date"
                type="date"
                required
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Número de Hóspedes</label>
              <input
                v-model.number="form.number_of_guests"
                type="number"
                min="1"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Valor Total a Receber (R$)</label>
              <input
                v-model="form.total_due"
                type="text"
                @input="e => handleCurrencyInput(e, 'total_due')"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Valor Sinal (R$)</label>
              <input
                v-model="form.deposit_amount"
                type="text"
                @input="e => handleCurrencyInput(e, 'deposit_amount')"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Valor Final (R$)</label>
              <input
                v-model="form.final_amount"
                type="text"
                @input="e => handleCurrencyInput(e, 'final_amount')"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Saldo a Receber (R$)</label>
              <input
                :value="formatCurrencyDisplay(calculateBalanceDue())"
                type="text"
                disabled
                class="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-50 text-gray-600 cursor-not-allowed focus:outline-none"
              />
              <p class="text-xs text-gray-500 mt-1">Calculado automaticamente: Valor Total - Sinal</p>
            </div>

            <div class="md:col-span-2">
              <label class="block text-sm font-medium text-gray-700 mb-1">Observação do Hóspede</label>
              <textarea
                v-model="form.guest_note"
                rows="3"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              ></textarea>
            </div>

            <div>
              <PersonSelect
                v-model="form.seller_id"
                :options="sellerOptions"
                :selected-person="selectedSeller"
                label="Corretor"
                @update:modelValue="handleSellerChange"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Valor Total a Pagar (R$)</label>
              <input
                v-model="form.total_payable"
                type="text"
                @input="e => handleCurrencyInput(e, 'total_payable')"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Valor Total Pago (R$)</label>
              <input
                v-model="form.total_paid"
                type="text"
                @input="e => handleCurrencyInput(e, 'total_paid')"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Saldo a Pagar (R$)</label>
              <input
                :value="formatCurrencyDisplay(calculateBalancePayable())"
                type="text"
                disabled
                class="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-50 text-gray-600 cursor-not-allowed focus:outline-none"
              />
              <p class="text-xs text-gray-500 mt-1">Calculado automaticamente: Total a Pagar - Total Pago</p>
            </div>

            <div class="md:col-span-2">
              <label class="block text-sm font-medium text-gray-700 mb-1">Observação do Corretor</label>
              <textarea
                v-model="form.seller_note"
                rows="3"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              ></textarea>
            </div>

            <!-- Anexos -->
            <div class="md:col-span-2">
              <label class="block text-sm font-medium text-gray-700 mb-2">Anexos</label>
              <AttachmentManager
                v-model="form.attachments"
                v-model:remove-attachment-ids="form.remove_attachment_ids"
                :accepted-types="'*'"
                :enable-reorder="true"
                :enable-lightbox="true"
              />
            </div>
          </div>
        </form>

        <div class="px-6 py-4 border-t border-gray-200 flex-shrink-0 bg-white flex justify-between items-center relative">
          <div v-if="formErrors.general" class="absolute left-6 -top-12 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg w-[calc(100%-3rem)] flex items-start justify-between">
            <span class="flex-1">{{ formErrors.general }}</span>
            <button 
              @click="formErrors.general = ''"
              class="ml-3 text-red-700 hover:text-red-900 flex-shrink-0"
              type="button"
            >
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
          <button
            v-if="editingBooking"
            type="button"
            @click="deleteConfirmBooking = editingBooking"
            class="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition"
          >
            Excluir
          </button>
          <div v-else></div>
          <div class="flex space-x-3">
            <button
              v-if="editingBooking && entryType !== 'cleaning'"
              type="button"
              @click="exportContract"
              :disabled="contractDownloading"
              class="px-4 py-2 border border-indigo-200 text-indigo-700 bg-indigo-50 rounded-lg hover:bg-indigo-100 transition disabled:opacity-50"
            >
              {{ contractDownloading ? 'Gerando contrato...' : 'Exportar contrato' }}
            </button>
            <button
              type="button"
              @click="closeModal"
              class="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition"
            >
              Cancelar
            </button>
            <button
              type="button"
              @click="saveBooking"
              :disabled="saving"
              class="px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition disabled:opacity-50"
            >
              {{ saving ? 'Salvando...' : 'Salvar' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <ConfirmationModal
      :isOpen="!!deleteConfirmBooking"
      title="Confirmar Exclusão"
      message="Tem certeza que deseja excluir esta locação? Esta ação não pode ser desfeita."
      :loading="deleting"
      @confirm="deleteBooking"
      @cancel="deleteConfirmBooking = null"
    />

    <QuickPersonModal
      :isOpen="quickPersonModalOpen.isOpen"
      :personType="quickPersonModalOpen.type"
      @save="handleQuickPersonSave"
      @close="closeQuickPersonModal"
    />
  </div>
</template>

<script>
import axios from 'axios'
import { router, navigateTo } from '../router.js'
import QuickPersonModal from './QuickPersonModal.vue'
import QuickServiceTypeModal from './QuickServiceTypeModal.vue'
import ConfirmationModal from './ConfirmationModal.vue'
import SelectWithFilter from './SelectWithFilter.vue'
import PersonSelect from './PersonSelect.vue'
import ServiceTypeSelect from './ServiceTypeSelect.vue'
import AttachmentManager from './AttachmentManager.vue'
import { useBrazilianMasks } from '../composables/useBrazilianMasks.js'
import { useApi } from '../composables/useApi.js'
import { BRAZILIAN_STATES } from '../constants/brazilianStates.js'

export default {
  components: {
    QuickPersonModal,
    QuickServiceTypeModal,
    ConfirmationModal,
    SelectWithFilter,
    PersonSelect,
    ServiceTypeSelect,
    AttachmentManager
  },
  data() {
    const { applyCurrencyMask, parseCurrencyToNumber, getWhatsAppLink } = useBrazilianMasks()

    return {
      applyCurrencyMask,
      parseCurrencyToNumber,
      getWhatsAppLink,
      currentMonth: new Date().getMonth(),
      currentYear: new Date().getFullYear(),
      bookings: [],
      loading: false,
      isModalOpen: false,
      editingBooking: null,
      entryType: 'booking',
      selectedPropertyId: null,
      customers: [],
      properties: [],
      sellers: [],
      cleaners: [],
      serviceTypes: [],
      saving: false,
      deleteConfirmBooking: null,
      deleting: false,
      contractDownloading: false,
      formErrors: {},
      form: this.getEmptyForm(),
      quickPersonModalOpen: {
        isOpen: false,
        type: null
      },
      quickServiceTypeModalOpen: false,
      stateOptions: BRAZILIAN_STATES,
      monthNames: [
        'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
        'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
      ],
      weekDays: ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb']
    }
  },

  computed: {
    stayIdToEdit() {
      return router.params?.stayId
    },

    calendarDays() {
      const firstDay = new Date(this.currentYear, this.currentMonth, 1)
      const lastDay = new Date(this.currentYear, this.currentMonth + 1, 0)
      const startDate = new Date(firstDay)
      startDate.setDate(startDate.getDate() - firstDay.getDay())
      
      const days = []
      const endDate = new Date(lastDay)
      endDate.setDate(endDate.getDate() + (6 - lastDay.getDay()))

      const current = new Date(startDate)
      while (current <= endDate) {
        days.push({
          date: new Date(current),
          isCurrentMonth: current.getMonth() === this.currentMonth,
          isToday: this.isToday(current)
        })
        current.setDate(current.getDate() + 1)
      }

      return days
    },

    sortedBookings() {
      let filtered = this.bookings
      if (this.selectedPropertyId !== null) {
        filtered = filtered.filter(b => b.property_id === this.selectedPropertyId)
      }
      return [...filtered].sort((a, b) => {
        return new Date(a.check_in_date) - new Date(b.check_in_date)
      })
    },

    activeCustomers() {
      return this.customers.filter(c => !c.blocked)
    },

    activeCleaners() {
      return this.cleaners.filter(c => !c.blocked)
    },

    activeSellers() {
      return this.sellers.filter(s => !s.blocked)
    },

    customerOptions() {
      return [
        { value: 'new', label: '+ Novo Hóspede' },
        ...this.activeCustomers.map(c => ({ value: String(c.id), label: c.name }))
      ]
    },

    cleanerOptions() {
      return [
        { value: 'new', label: '+ Nova Faxineira' },
        ...this.activeCleaners.map(c => ({ value: String(c.id), label: c.name }))
      ]
    },

    sellerOptions() {
      return [
        { value: 'new', label: '+ Novo Corretor' },
        ...this.activeSellers.map(s => ({ value: String(s.id), label: s.name }))
      ]
    },

    selectedCustomer() {
      const id = String(this.form.customer_id || '')
      if (!id) return null
      return this.customers.find(c => String(c.id) === id) || null
    },

    selectedCleaner() {
      const id = String(this.form.customer_id || '')
      if (!id) return null
      return this.cleaners.find(c => String(c.id) === id) || null
    },

    selectedSeller() {
      const id = String(this.form.seller_id || '')
      if (!id) return null
      return this.sellers.find(s => String(s.id) === id) || null
    },

    serviceTypeOptions() {
      return [
        { value: 'new', label: '+ Novo Tipo de Serviço' },
        ...this.serviceTypes.map(st => ({ value: String(st.id), label: st.name }))
      ]
    }
  },

  watch: {
    stayIdToEdit(newVal) {
      if (newVal) {
        const booking = this.bookings.find(b => b.id === newVal)
        if (booking) {
          this.editBooking(booking)
          // Limpar o parâmetro para próximas navegações
          router.params.stayId = null
        }
      }
    },

    currentMonth(newVal) {
      this.loadServicesByMonth()
    },

    currentYear(newVal) {
      this.loadServicesByMonth()
    },

    'form.attachments': {
      handler(newVal) {
        // Atualizar attachments_order com IDs dos anexos existentes na ordem atual
        if (newVal && Array.isArray(newVal)) {
          const attachmentIds = newVal
            .filter(att => att && att.id)
            .map(att => att.id)
          this.form.attachments_order = attachmentIds
        }
      },
      deep: true
    }
  },

  mounted() {
    this.loadData()
    // Se já temos um stayId ao montar, tentar editar
    if (this.stayIdToEdit) {
      setTimeout(() => {
        const booking = this.bookings.find(b => b.id === this.stayIdToEdit)
        if (booking) {
          this.editBooking(booking)
          router.params.stayId = null
        }
      }, 500)
    }
  },

  methods: {
    getEmptyForm(type = 'booking') {
      return {
        customer_id: '',
        property_id: '',
        seller_id: '',
        service_type_id: '',
        guest_name: '',
        guest_email: '',
        property_name: '',
        property_type: type === 'cleaning' ? 'cleaning' : '',
        check_in_date: '',
        check_out_date: '',
        number_of_guests: 1,
        total_due: '0,00',
        deposit_amount: '0,00',
        final_amount: '0,00',
        guest_note: '',
        total_payable: '0,00',
        total_paid: '0,00',
        seller_note: '',
        description: '',
        attachments: [],
        remove_attachment_ids: [],
        attachments_order: []
      }
    },

    async loadData() {
      this.loading = true
      try {
        const { getPeople, getProperties, getServiceTypes } = useApi()
        await Promise.all([
          this.loadServicesByMonth(),
          this.loadCustomers(getPeople),
          this.loadProperties(getProperties),
          this.loadSellers(getPeople),
          this.loadCleaners(getPeople),
          this.loadServiceTypes(getServiceTypes)
        ])
      } finally {
        this.loading = false
      }
    },

    async loadServicesByMonth() {
      const startDate = new Date(this.currentYear, this.currentMonth, 1)
      const endDate = new Date(this.currentYear, this.currentMonth + 1, 0)

      const startDateString = startDate.toISOString().split('T')[0]
      const endDateString = endDate.toISOString().split('T')[0]

      try {
        const { getServices } = useApi()
        const { data, error } = await getServices(startDateString, endDateString)
        if (!error) this.bookings = data
      } catch (err) {
        console.error('Error loading bookings by month:', err)
      }
    },

    async loadBookings(apiMethod) {
      try {
        const { data, error } = await apiMethod()
        if (!error) this.bookings = data
      } catch (err) {
        console.error('Error loading bookings:', err)
      }
    },

    async loadCustomers(apiMethod) {
      try {
        const { data, error } = await apiMethod('Customer')
        if (!error) this.customers = data
      } catch (err) {
        console.error('Error loading customers:', err)
      }
    },

    async loadProperties(apiMethod) {
      try {
        const { data, error } = await apiMethod()
        if (!error) {
          this.properties = data
          // Se há imóveis e nenhum está selecionado, selecionar o primeiro
          if (this.properties.length > 0 && this.selectedPropertyId === null) {
            this.selectedPropertyId = this.properties[0].id
          }
        }
      } catch (err) {
        console.error('Error loading properties:', err)
      }
    },

    async loadSellers(apiMethod) {
      try {
        const { data, error } = await apiMethod('Seller')
        if (!error) this.sellers = data
      } catch (err) {
        console.error('Error loading sellers:', err)
      }
    },

    async loadCleaners(apiMethod) {
      try {
        const { data, error } = await apiMethod('Cleaner')
        if (!error) this.cleaners = data
      } catch (err) {
        console.error('Error loading cleaners:', err)
      }
    },

    async loadServiceTypes(apiMethod) {
      try {
        const { data, error } = await apiMethod()
        if (!error) this.serviceTypes = data
      } catch (err) {
        console.error('Error loading service types:', err)
      }
    },

    getBookingsForDay(date) {
      let filtered = this.bookings
      if (this.selectedPropertyId !== null) {
        filtered = filtered.filter(b => b.property_id === this.selectedPropertyId)
      }
      return filtered.filter(booking => {
        const checkIn = new Date(booking.check_in_date)
        const checkOut = new Date(booking.check_out_date)
        return date >= checkIn && date <= checkOut
      })
    },

    getBookingColor(booking) {
      if (booking.property_type === 'cleaning') {
        return 'bg-amber-100 text-amber-800 hover:bg-amber-200'
      }
      return 'bg-indigo-100 text-indigo-800 hover:bg-indigo-200'
    },

    getBookingLabel(booking) {
      if (booking.property_type === 'cleaning') {
        return `${booking.guest_name} (Faxina)`
      }
      return booking.guest_name
    },

    calculateBalanceDue() {
      const total = this.parseCurrencyToNumber(this.form.total_due || '0')
      const deposit = this.parseCurrencyToNumber(this.form.deposit_amount || '0')
      return Math.max(0, total - deposit)
    },

    calculateBalancePayable() {
      const totalPayable = this.parseCurrencyToNumber(this.form.total_payable || '0')
      const totalPaid = this.parseCurrencyToNumber(this.form.total_paid || '0')
      return Math.max(0, totalPayable - totalPaid)
    },

    formatCurrencyDisplay(value) {
      // Garantir que é um número
      const numValue = typeof value === 'string' ? parseFloat(value.replace(',', '.')) : parseFloat(value || 0)
      
      // Formatar com 2 casas decimais usando pt-BR locale
      return numValue.toLocaleString('pt-BR', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
      })
    },

    handleCurrencyInput(event, fieldName) {
      const cursorPosition = event.target.selectionStart
      const oldValue = event.target.value
      const oldLength = oldValue.length
      
      // Aplica a máscara
      const newValue = this.applyCurrencyMask(event.target.value)
      
      // Atualiza o form
      this.form[fieldName] = newValue
      
      // Restaura a posição do cursor após a formatação
      this.$nextTick(() => {
        const newLength = newValue.length
        const diff = newLength - oldLength
        const newCursorPosition = Math.max(0, cursorPosition + diff)
        event.target.setSelectionRange(newCursorPosition, newCursorPosition)
      })
    },

    isToday(date) {
      const today = new Date()
      return date.getDate() === today.getDate() &&
             date.getMonth() === today.getMonth() &&
             date.getFullYear() === today.getFullYear()
    },

    formatDate(dateString) {
      const date = new Date(dateString)
      return date.toLocaleDateString('pt-BR')
    },

    previousMonth() {
      if (this.currentMonth === 0) {
        this.currentMonth = 11
        this.currentYear--
      } else {
        this.currentMonth--
      }
    },

    nextMonth() {
      if (this.currentMonth === 11) {
        this.currentMonth = 0
        this.currentYear++
      } else {
        this.currentMonth++
      }
    },

    goToToday() {
      const today = new Date()
      this.currentMonth = today.getMonth()
      this.currentYear = today.getFullYear()
    },

    navigateToProperties() {
      navigateTo('properties')
    },

    openCreateModal(type = 'booking') {
      this.entryType = type
      this.editingBooking = null
      this.form = this.getEmptyForm(type)
      if (this.selectedPropertyId !== null) {
        this.form.property_id = this.selectedPropertyId
      }
      this.formErrors = {}
      this.isModalOpen = true
    },

    viewBooking(booking) {
      const type = booking.property_type === 'cleaning' ? 'cleaning' : 'booking'
      this.entryType = type
      this.editingBooking = booking
      
      // Função helper para formatar valor monetário
      const formatMoneyValue = (value) => {
        const numValue = typeof value === 'string' ? parseFloat(value.replace(/[^0-9.-]/g, '')) : parseFloat(value || 0)
        return this.formatCurrencyDisplay(numValue)
      }
      
      this.form = {
        ...this.getEmptyForm(type),
        ...booking,
        customer_id: booking.customer_id ? String(booking.customer_id) : '',
        property_id: booking.property_id || '',
        seller_id: booking.seller_id ? String(booking.seller_id) : '',
        property_type: booking.property_type || (type === 'cleaning' ? 'cleaning' : ''),
        service_type_id: booking.service_type_id ? String(booking.service_type_id) : '',
        // Formatar valores monetários para exibição
        total_due: formatMoneyValue(booking.total_due),
        deposit_amount: formatMoneyValue(booking.deposit_amount),
        final_amount: formatMoneyValue(booking.final_amount),
        total_payable: formatMoneyValue(booking.total_payable),
        total_paid: formatMoneyValue(booking.total_paid)
      }
      this.isModalOpen = true
    },

    editBooking(booking) {
      const type = booking.property_type === 'cleaning' ? 'cleaning' : 'booking'
      this.entryType = type
      this.editingBooking = booking
      
      // Função helper para formatar valor monetário
      const formatMoneyValue = (value) => {
        const numValue = typeof value === 'string' ? parseFloat(value.replace(/[^0-9.-]/g, '')) : parseFloat(value || 0)
        return this.formatCurrencyDisplay(numValue)
      }
      
      this.form = {
        ...this.getEmptyForm(type),
        ...booking,
        customer_id: booking.customer_id ? String(booking.customer_id) : '',
        property_id: booking.property_id || '',
        seller_id: booking.seller_id ? String(booking.seller_id) : '',
        property_type: booking.property_type || (type === 'cleaning' ? 'cleaning' : ''),
        service_type_id: booking.service_type_id ? String(booking.service_type_id) : '',
        // Formatar valores monetários para exibição
        total_due: formatMoneyValue(booking.total_due),
        deposit_amount: formatMoneyValue(booking.deposit_amount),
        final_amount: formatMoneyValue(booking.final_amount),
        total_payable: formatMoneyValue(booking.total_payable),
        total_paid: formatMoneyValue(booking.total_paid)
      }
      this.formErrors = {}
      this.isModalOpen = true
    },

    closeModal() {
      // Liberar URLs de preview de novos arquivos (File/Blob)
      if (this.form.attachments) {
        this.form.attachments.forEach(item => {
          const isFile = (typeof File !== 'undefined' && item instanceof File) ||
            (typeof Blob !== 'undefined' && item instanceof Blob)
          if (isFile && item.previewUrl) {
            URL.revokeObjectURL(item.previewUrl)
          }
        })
      }
      
      this.isModalOpen = false
      this.editingBooking = null
      this.form = this.getEmptyForm()
      this.entryType = 'booking'
      this.formErrors = {}
    },

    buildServiceFormData() {
      const isCleaning = this.entryType === 'cleaning'
      
      let selectedPerson
      if (isCleaning) {
        selectedPerson = this.cleaners.find(c => String(c.id) === String(this.form.customer_id))
      } else {
        selectedPerson = this.customers.find(c => String(c.id) === String(this.form.customer_id))
      }
      
      const selectedProperty = this.properties.find(p => String(p.id) === String(this.form.property_id))
      
      // Verificar se há novos anexos (arquivos File/Blob)
      const isFile = (item) => (typeof File !== 'undefined' && item instanceof File) ||
        (typeof Blob !== 'undefined' && item instanceof Blob)
      const newFiles = (this.form.attachments || []).filter(item => isFile(item))
      const hasNewFiles = newFiles.length > 0
      const hasRemovedAttachments = this.form.remove_attachment_ids && this.form.remove_attachment_ids.length > 0
      const hasAttachmentsOrder = this.form.attachments_order && this.form.attachments_order.length > 0

      // Dados do serviço/locação
      const serviceData = {
        customer_id: this.form.customer_id,
        property_id: this.form.property_id,
        seller_id: this.form.seller_id || null,
        service_type_id: this.form.service_type_id || null,
        guest_name: selectedPerson ? selectedPerson.name : this.form.guest_name,
        guest_email: selectedPerson && selectedPerson.email ? selectedPerson.email : this.form.guest_email,
        property_name: selectedProperty ? selectedProperty.name : this.form.property_name,
        property_type: isCleaning ? 'cleaning' : (this.form.property_type || ''),
        check_in_date: this.form.check_in_date,
        check_out_date: this.form.check_out_date,
        number_of_guests: this.form.number_of_guests,
        total_due: this.parseCurrencyToNumber(this.form.total_due || '0'),
        deposit_amount: this.parseCurrencyToNumber(this.form.deposit_amount || '0'),
        final_amount: this.parseCurrencyToNumber(this.form.final_amount || '0'),
        total_payable: this.parseCurrencyToNumber(this.form.total_payable || '0'),
        total_paid: this.parseCurrencyToNumber(this.form.total_paid || '0'),
        balance_due: this.calculateBalanceDue(),
        balance_payable: this.calculateBalancePayable(),
        guest_note: this.form.guest_note || '',
        seller_note: this.form.seller_note || '',
        description: this.form.description || ''
      }

      // Se vamos usar JSON (não FormData), adicionar arrays ao serviceData
      if (!hasNewFiles && !hasRemovedAttachments && !hasAttachmentsOrder) {
        return { useFormData: false, payload: serviceData }
      }

      // Para JSON, incluir arrays apenas se tiverem elementos
      if (!hasNewFiles) {
        if (hasRemovedAttachments) {
          serviceData.remove_attachment_ids = this.form.remove_attachment_ids
        }
        if (hasAttachmentsOrder) {
          serviceData.attachments_order = this.form.attachments_order
        }
        return { useFormData: false, payload: serviceData }
      }

      // Construir FormData para enviar arquivos
      const formData = new FormData()
      
      // Adicionar todos os campos do serviço com prefixo 'service[]'
      Object.keys(serviceData).forEach(key => {
        const value = serviceData[key]
        if (value !== null && value !== undefined && value !== '') {
          formData.append(`service[${key}]`, value)
        }
      })

      // Adicionar novos arquivos
      newFiles.forEach((file) => {
        formData.append('service[attachments][]', file, file.name)
      })

      // Adicionar IDs de anexos a remover
      if (hasRemovedAttachments) {
        this.form.remove_attachment_ids.forEach(id => {
          formData.append('service[remove_attachment_ids][]', id)
        })
      }

      // Adicionar ordem dos anexos
      if (this.form.attachments_order && this.form.attachments_order.length > 0) {
        this.form.attachments_order.forEach(id => {
          formData.append('service[attachments_order][]', id)
        })
      }

      return { useFormData: true, payload: formData }
    },

    async saveBooking() {
      this.saving = true
      this.formErrors = {}

      try {
        const { post, put, postFormData, putFormData } = useApi()
        const { useFormData, payload } = this.buildServiceFormData()

        let result
        if (this.editingBooking) {
          if (useFormData) {
            result = await putFormData(`/api/v1/services/${this.editingBooking.id}`, payload)
          } else {
            result = await put(`/api/v1/services/${this.editingBooking.id}`, { service: payload })
          }
        } else {
          if (useFormData) {
            result = await postFormData('/api/v1/services', payload)
          } else {
            result = await post('/api/v1/services', { service: payload })
          }
        }

        if (result.error) {
          this.formErrors.general = result.error.response?.data?.errors?.join(', ') || 'Erro ao salvar locação'
          return
        }

        this.closeModal()
        this.loadServicesByMonth()
      } catch (err) {
        this.formErrors.general = err.response?.data?.errors?.join(', ') || 'Erro ao salvar locação'
      } finally {
        this.saving = false
      }
    },

    confirmDelete(booking) {
      this.deleteConfirmBooking = booking
    },

    handleCustomerChange(value) {
      if (value === 'new') {
        this.quickPersonModalOpen = { isOpen: true, type: 'Customer' }
        this.form.customer_id = ''
      }
    },

    handleCleanerChange(value) {
      if (value === 'new') {
        this.quickPersonModalOpen = { isOpen: true, type: 'Cleaner' }
        this.form.customer_id = ''
      }
    },

    handleSellerChange(value) {
      if (value === 'new') {
        this.quickPersonModalOpen = { isOpen: true, type: 'Seller' }
        this.form.seller_id = ''
      }
    },

    handleQuickPersonSave(person) {
      if (this.quickPersonModalOpen.type === 'Customer') {
        this.form.customer_id = person.id
        this.loadCustomers(useApi().getPeople)
      } else if (this.quickPersonModalOpen.type === 'Cleaner') {
        this.form.customer_id = person.id
        this.loadCleaners(useApi().getPeople)
      } else if (this.quickPersonModalOpen.type === 'Seller') {
        this.form.seller_id = person.id
        this.loadSellers(useApi().getPeople)
      }
      this.closeQuickPersonModal()
    },

    closeQuickPersonModal() {
      this.quickPersonModalOpen = { isOpen: false, type: null }
    },

    handleServiceTypeChange(value) {
      if (value === 'new') {
        this.quickServiceTypeModalOpen = true
        this.form.service_type_id = ''
      }
    },

    handleQuickServiceTypeSave(serviceType) {
      this.form.service_type_id = serviceType.id
      this.loadServiceTypes(useApi().getServiceTypes)
    },

    closeQuickServiceTypeModal() {
      this.quickServiceTypeModalOpen = false
    },

    async deleteBooking() {
      this.deleting = true

      try {
        const { delete: deleteApi } = useApi()
        const { error } = await deleteApi(`/api/v1/services/${this.deleteConfirmBooking.id}`)

        if (!error) {
          this.deleteConfirmBooking = null
          this.closeModal()
          this.loadServicesByMonth()
        }
      } catch (err) {
        console.error('Error deleting booking:', err)
        this.deleteConfirmBooking = null
      } finally {
        this.deleting = false
      }
    },

    async exportContract() {
      if (!this.editingBooking?.id) return

      this.contractDownloading = true
      try {
        const { getHeaders } = useApi()
        const requestUrl = `${window.location.origin}/api/v1/stays/${this.editingBooking.id}/contract`
        const response = await axios.get(requestUrl, {
          headers: getHeaders(),
          responseType: 'blob'
        })

        const blob = new Blob([response.data], { type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' })
        const blobUrl = window.URL.createObjectURL(blob)
        const link = document.createElement('a')
        const guest = (this.editingBooking.guest_name || 'locacao').replace(/[\\/:*?"<>|]/g, '')

        link.href = blobUrl
        link.setAttribute('download', `Contrato-${guest}.docx`)
        document.body.appendChild(link)
        link.click()
        link.remove()
        window.URL.revokeObjectURL(blobUrl)
      } catch (err) {
        console.error('Error exporting contract:', err)
        this.formErrors.general = 'Não foi possível exportar o contrato agora.'
      } finally {
        this.contractDownloading = false
      }
    }
  }
}
</script>
