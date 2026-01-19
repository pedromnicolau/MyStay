<template>
  <div class="min-h-screen bg-gray-50">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div class="mb-6 flex justify-between items-center">
        <h1 class="text-3xl font-bold text-gray-900">Locações</h1>
        <div class="flex items-center space-x-3">
          <button
            @click="openCreateModal('booking')"
            class="bg-indigo-600 text-white px-6 py-2.5 rounded-lg hover:bg-indigo-700 transition flex items-center space-x-2 shadow-sm"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
            </svg>
            <span>Nova Locação</span>
          </button>

          <button
            @click="openCreateModal('cleaning')"
            class="bg-emerald-600 text-white px-6 py-2.5 rounded-lg hover:bg-emerald-700 transition flex items-center space-x-2 shadow-sm"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
            </svg>
            <span>Nova Faxina</span>
          </button>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow-sm p-6 mb-6">
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-2">Filtrar por Imóvel</label>
          <select
            v-model.number="selectedPropertyId"
            class="w-full md:w-64 px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
          >
            <option value="">Todos os imóveis</option>
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
              booking.status === 'confirmed' ? 'bg-green-50 border-green-500' : 
              booking.status === 'pending' ? 'bg-yellow-50 border-yellow-500' : 
              booking.status === 'cancelled' ? 'bg-red-50 border-red-500' : 
              'bg-blue-50 border-blue-500'
            ]"
          >
            <div class="flex justify-between items-start">
              <div class="flex-1">
                <div class="flex items-center space-x-2 mb-1">
                  <h4 class="font-semibold text-gray-900">{{ getBookingLabel(booking) }}</h4>
                  <span
                    :class="[
                      'text-xs px-2 py-0.5 rounded-full',
                      booking.status === 'confirmed' ? 'bg-green-200 text-green-800' : 
                      booking.status === 'pending' ? 'bg-yellow-200 text-yellow-800' : 
                      booking.status === 'cancelled' ? 'bg-red-200 text-red-800' : 
                      'bg-blue-200 text-blue-800'
                    ]"
                  >
                    {{ getStatusLabel(booking.status) }}
                  </span>
                  <span
                    v-if="booking.property_type === 'cleaning'"
                    class="text-xs px-2 py-0.5 rounded-full bg-emerald-200 text-emerald-800"
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
            {{ editingBooking ? (entryType === 'cleaning' ? 'Editar Faxina' : 'Editar Locação') : (entryType === 'cleaning' ? 'Nova Faxina' : 'Nova Locação') }}
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
                <label class="block text-sm font-medium text-gray-700 mb-1">Faxineira *</label>
                <select
                  v-model.number="form.customer_id"
                  @change="handleCleanerChange"
                  required
                  class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                >
                  <option value="new" class="font-semibold text-indigo-600">+ Nova Faxineira</option>
                  <option value="" disabled>Selecione uma faxineira</option>
                  <option v-for="cleaner in cleaners" :key="cleaner.id" :value="cleaner.id">
                    {{ cleaner.name }}
                  </option>
                </select>
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
              <label class="block text-sm font-medium text-gray-700 mb-1">Hóspede *</label>
              <select
                v-model.number="form.customer_id"
                @change="handleCustomerChange"
                required
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              >
                <option value="new" class="font-semibold text-indigo-600">+ Novo Hóspede</option>
                <option value="" disabled>Selecione um hóspede</option>
                <option v-for="customer in customers" :key="customer.id" :value="customer.id">
                  {{ customer.name }}
                </option>
              </select>
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
                v-model.number="form.total_due"
                type="number"
                step="0.01"
                min="0"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Valor Sinal (R$)</label>
              <input
                v-model.number="form.deposit_amount"
                type="number"
                step="0.01"
                min="0"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Valor Final (R$)</label>
              <input
                v-model.number="form.final_amount"
                type="number"
                step="0.01"
                min="0"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Saldo a Receber (R$)</label>
              <input
                v-model.number="form.balance_due"
                type="number"
                step="0.01"
                min="0"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
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
              <label class="block text-sm font-medium text-gray-700 mb-1">Corretor</label>
              <select
                v-model.number="form.seller_id"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              >
                <option value="">Selecione um corretor</option>
                <option v-for="seller in sellers" :key="seller.id" :value="seller.id">
                  {{ seller.name }}
                </option>
              </select>
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
              <label class="block text-sm font-medium text-gray-700 mb-1">Valor Total Pago (R$)</label>
              <input
                v-model.number="form.total_paid"
                type="number"
                step="0.01"
                min="0"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Saldo a Pagar (R$)</label>
              <input
                v-model.number="form.balance_payable"
                type="number"
                step="0.01"
                min="0"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div class="md:col-span-2">
              <label class="block text-sm font-medium text-gray-700 mb-1">Observação do Corretor</label>
              <textarea
                v-model="form.seller_note"
                rows="3"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              ></textarea>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Status</label>
              <select
                v-model="form.status"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              >
                <option value="pending">Pendente</option>
                <option value="confirmed">Confirmado</option>
                <option value="cancelled">Cancelado</option>
                <option value="completed">Concluído</option>
              </select>
            </div>
          </div>
        </form>

        <div class="px-6 py-4 border-t border-gray-200 flex-shrink-0 bg-white flex justify-end space-x-3 relative">
          <div v-if="formErrors.general" class="absolute left-6 -top-12 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg w-[calc(100%-3rem)]">
            {{ formErrors.general }}
          </div>
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

    <div
      v-if="deleteConfirmBooking"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
      @click.self="deleteConfirmBooking = null"
    >
      <div class="bg-white rounded-lg shadow-xl max-w-md w-full p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">Confirmar Exclusão</h3>
        <p class="text-gray-600 mb-6">
          Tem certeza que deseja excluir esta locação? Esta ação não pode ser desfeita.
        </p>
        <div class="flex justify-end space-x-3">
          <button
            @click="deleteConfirmBooking = null"
            class="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition"
          >
            Cancelar
          </button>
          <button
            @click="deleteBooking"
            :disabled="deleting"
            class="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition disabled:opacity-50"
          >
            {{ deleting ? 'Excluindo...' : 'Excluir' }}
          </button>
        </div>
      </div>
    </div>

    <div
      v-if="isQuickCustomerModalOpen"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
      @click.self="closeQuickCustomerModal"
    >
      <div class="bg-white rounded-lg shadow-xl max-w-md w-full max-h-[90vh] flex flex-col overflow-hidden">
        <div class="px-6 py-4 border-b border-gray-200 flex justify-between items-center flex-shrink-0">
          <h2 class="text-xl font-semibold text-gray-900">Novo Hóspede</h2>
          <button @click="closeQuickCustomerModal" class="text-gray-400 hover:text-gray-600">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <form @submit.prevent="saveQuickCustomer" class="px-6 py-4 overflow-y-auto flex-1 flex flex-col">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Nome *</label>
              <input
                v-model="quickCustomerForm.name"
                type="text"
                required
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">E-mail</label>
              <input
                v-model="quickCustomerForm.email"
                type="email"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Telefone *</label>
              <input
                v-model="quickCustomerForm.phone"
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
                v-model="quickCustomerForm.cpf"
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
                v-model="quickCustomerForm.rg"
                @input="applyRgMask"
                type="text"
                maxlength="12"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Profissão</label>
              <input
                v-model="quickCustomerForm.profession"
                type="text"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Estado Civil</label>
              <select
                v-model="quickCustomerForm.marital_status"
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
                v-model="quickCustomerForm.zip"
                @input="applyZipMask"
                type="text"
                placeholder="00000-000"
                maxlength="9"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Endereço</label>
              <input
                v-model="quickCustomerForm.address"
                type="text"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Número</label>
              <input
                v-model="quickCustomerForm.number"
                type="text"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Bairro</label>
              <input
                v-model="quickCustomerForm.neighborhood"
                type="text"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Cidade</label>
              <input
                v-model="quickCustomerForm.city"
                type="text"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Estado</label>
              <select
                v-model="quickCustomerForm.state"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              >
                <option value="">Selecione</option>
                <option v-for="state in stateOptions" :key="state.value" :value="state.value">
                  {{ state.label }}
                </option>
              </select>
            </div>

            <div class="md:col-span-2">
              <label class="block text-sm font-medium text-gray-700 mb-1">Observações</label>
              <textarea
                v-model="quickCustomerForm.note"
                rows="3"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              ></textarea>
            </div>

            <div class="md:col-span-2">
              <label class="flex items-center space-x-2">
                <input
                  v-model="quickCustomerForm.blocked"
                  type="checkbox"
                  class="w-4 h-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500"
                />
                <span class="text-sm font-medium text-gray-700">Cliente bloqueado</span>
              </label>
            </div>
          </div>
        </form>

        <div class="px-6 py-4 border-t border-gray-200 flex-shrink-0 bg-white flex justify-end space-x-3 relative">
          <div v-if="quickCustomerErrors.general" class="absolute left-6 -top-12 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg w-[calc(100%-3rem)]">
            {{ quickCustomerErrors.general }}
          </div>
          <button
            type="button"
            @click="closeQuickCustomerModal"
            class="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition"
          >
            Cancelar
          </button>
          <button
            type="button"
            @click="saveQuickCustomer"
            :disabled="savingQuickCustomer"
            class="px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition disabled:opacity-50"
          >
            {{ savingQuickCustomer ? 'Salvando...' : 'Salvar' }}
          </button>
        </div>
      </div>
    </div>

    <div
      v-if="isQuickCleanerModalOpen"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
      @click.self="closeQuickCleanerModal"
    >
      <div class="bg-white rounded-lg shadow-xl max-w-md w-full max-h-[90vh] flex flex-col overflow-hidden">
        <div class="px-6 py-4 border-b border-gray-200 flex justify-between items-center flex-shrink-0">
          <h2 class="text-xl font-semibold text-gray-900">Nova Faxineira</h2>
          <button @click="closeQuickCleanerModal" class="text-gray-400 hover:text-gray-600">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <form @submit.prevent="saveQuickCleaner" class="px-6 py-4 overflow-y-auto flex-1 flex flex-col">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Nome *</label>
              <input
                v-model="quickCleanerForm.name"
                type="text"
                required
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">E-mail</label>
              <input
                v-model="quickCleanerForm.email"
                type="email"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Telefone *</label>
              <input
                v-model="quickCleanerForm.phone"
                @input="applyPhoneMaskCleaner"
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
                v-model="quickCleanerForm.cpf"
                @input="applyCpfMaskCleaner"
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
                v-model="quickCleanerForm.rg"
                @input="applyRgMaskCleaner"
                type="text"
                maxlength="12"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Profissão</label>
              <input
                v-model="quickCleanerForm.profession"
                type="text"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Estado Civil</label>
              <select
                v-model="quickCleanerForm.marital_status"
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
                v-model="quickCleanerForm.zip"
                @input="applyZipMaskCleaner"
                type="text"
                placeholder="00000-000"
                maxlength="9"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Endereço</label>
              <input
                v-model="quickCleanerForm.address"
                type="text"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Número</label>
              <input
                v-model="quickCleanerForm.number"
                type="text"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Bairro</label>
              <input
                v-model="quickCleanerForm.neighborhood"
                type="text"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Cidade</label>
              <input
                v-model="quickCleanerForm.city"
                type="text"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Estado</label>
              <select
                v-model="quickCleanerForm.state"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              >
                <option value="">Selecione</option>
                <option v-for="state in stateOptions" :key="state.value" :value="state.value">
                  {{ state.label }}
                </option>
              </select>
            </div>

            <div class="md:col-span-2">
              <label class="block text-sm font-medium text-gray-700 mb-1">Observações</label>
              <textarea
                v-model="quickCleanerForm.note"
                rows="3"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              ></textarea>
            </div>

            <div class="md:col-span-2">
              <label class="flex items-center space-x-2">
                <input
                  v-model="quickCleanerForm.blocked"
                  type="checkbox"
                  class="w-4 h-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500"
                />
                <span class="text-sm font-medium text-gray-700">Faxineira bloqueada</span>
              </label>
            </div>
          </div>
        </form>

        <div class="px-6 py-4 border-t border-gray-200 flex-shrink-0 bg-white flex justify-end space-x-3 relative">
          <div v-if="quickCleanerErrors.general" class="absolute left-6 -top-12 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg w-[calc(100%-3rem)]">
            {{ quickCleanerErrors.general }}
          </div>
          <button
            type="button"
            @click="closeQuickCleanerModal"
            class="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition"
          >
            Cancelar
          </button>
          <button
            type="button"
            @click="saveQuickCleaner"
            :disabled="savingQuickCleaner"
            class="px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition disabled:opacity-50"
          >
            {{ savingQuickCleaner ? 'Salvando...' : 'Salvar' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  data() {
    return {
      currentMonth: new Date().getMonth(),
      currentYear: new Date().getFullYear(),
      bookings: [],
      loading: false,
      isModalOpen: false,
      editingBooking: null,
      entryType: 'booking',
      selectedPropertyId: '',
      customers: [],
      properties: [],
      sellers: [],
      cleaners: [],
      saving: false,
      deleteConfirmBooking: null,
      deleting: false,
      formErrors: {},
      form: this.getEmptyForm(),
      isQuickCustomerModalOpen: false,
      savingQuickCustomer: false,
      quickCustomerForm: {
        name: '',
        email: '',
        phone: '',
        cpf: '',
        rg: '',
        profession: '',
        marital_status: '',
        zip: '',
        address: '',
        number: '',
        neighborhood: '',
        city: '',
        state: '',
        note: '',
        blocked: false,
        type: 'Customer'
      },
      quickCustomerErrors: {},
      isQuickCleanerModalOpen: false,
      savingQuickCleaner: false,
      quickCleanerForm: {
        name: '',
        email: '',
        phone: '',
        cpf: '',
        rg: '',
        profession: '',
        marital_status: '',
        zip: '',
        address: '',
        number: '',
        neighborhood: '',
        city: '',
        state: '',
        note: '',
        blocked: false,
        type: 'Cleaner'
      },
      quickCleanerErrors: {},
      stateOptions: [
        { value: 'AC', label: 'Acre' },
        { value: 'AL', label: 'Alagoas' },
        { value: 'AP', label: 'Amapá' },
        { value: 'AM', label: 'Amazonas' },
        { value: 'BA', label: 'Bahia' },
        { value: 'CE', label: 'Ceará' },
        { value: 'DF', label: 'Distrito Federal' },
        { value: 'ES', label: 'Espírito Santo' },
        { value: 'GO', label: 'Goiás' },
        { value: 'MA', label: 'Maranhão' },
        { value: 'MT', label: 'Mato Grosso' },
        { value: 'MS', label: 'Mato Grosso do Sul' },
        { value: 'MG', label: 'Minas Gerais' },
        { value: 'PA', label: 'Pará' },
        { value: 'PB', label: 'Paraíba' },
        { value: 'PR', label: 'Paraná' },
        { value: 'PE', label: 'Pernambuco' },
        { value: 'PI', label: 'Piauí' },
        { value: 'RJ', label: 'Rio de Janeiro' },
        { value: 'RN', label: 'Rio Grande do Norte' },
        { value: 'RS', label: 'Rio Grande do Sul' },
        { value: 'RO', label: 'Rondônia' },
        { value: 'RR', label: 'Roraima' },
        { value: 'SC', label: 'Santa Catarina' },
        { value: 'SP', label: 'São Paulo' },
        { value: 'SE', label: 'Sergipe' },
        { value: 'TO', label: 'Tocantins'
        }
      ],
      monthNames: [
        'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
        'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
      ],
      weekDays: ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb']
    }
  },

  computed: {
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
      if (this.selectedPropertyId) {
        filtered = filtered.filter(b => b.property_id === this.selectedPropertyId)
      }
      return [...filtered].sort((a, b) => {
        return new Date(a.check_in_date) - new Date(b.check_in_date)
      })
    }
  },

  mounted() {
    this.loadData()
  },

  methods: {
    getEmptyForm(defaultStatus = 'pending', type = 'booking') {
      return {
        customer_id: '',
        property_id: '',
        seller_id: '',
        guest_name: '',
        guest_email: '',
        property_name: '',
        property_type: type === 'cleaning' ? 'cleaning' : '',
        check_in_date: '',
        check_out_date: '',
        number_of_guests: 1,
        total_due: 0,
        deposit_amount: 0,
        final_amount: 0,
        balance_due: 0,
        guest_note: '',
        total_payable: 0,
        total_paid: 0,
        balance_payable: 0,
        seller_note: '',
        status: defaultStatus,
        total_price: 0,
        description: ''
      }
    },

    async loadData() {
      this.loading = true
      try {
        await Promise.all([this.loadBookings(), this.loadCustomers(), this.loadProperties(), this.loadSellers(), this.loadCleaners()])
      } finally {
        this.loading = false
      }
    },

    async loadBookings() {
      try {
        const token = localStorage.getItem('token')
        const response = await axios.get('/api/v1/stays', {
          headers: { Authorization: `Bearer ${token}` }
        })
        this.bookings = response.data
      } catch (err) {
        console.error('Error loading bookings:', err)
      }
    },

    async loadCustomers() {
      try {
        const token = localStorage.getItem('token')
        const response = await axios.get('/api/v1/people?type=Customer', {
          headers: { Authorization: `Bearer ${token}` }
        })
        this.customers = response.data
      } catch (err) {
        console.error('Error loading customers:', err)
      }
    },

    async loadProperties() {
      try {
        const token = localStorage.getItem('token')
        const response = await axios.get('/api/v1/properties', {
          headers: { Authorization: `Bearer ${token}` }
        })
        this.properties = response.data
      } catch (err) {
        console.error('Error loading properties:', err)
      }
    },

    async loadSellers() {
      try {
        const token = localStorage.getItem('token')
        const response = await axios.get('/api/v1/people?type=Seller', {
          headers: { Authorization: `Bearer ${token}` }
        })
        this.sellers = response.data
      } catch (err) {
        console.error('Error loading sellers:', err)
      }
    },

    async loadCleaners() {
      try {
        const token = localStorage.getItem('token')
        const response = await axios.get('/api/v1/people?type=Cleaner', {
          headers: { Authorization: `Bearer ${token}` }
        })
        this.cleaners = response.data
      } catch (err) {
        console.error('Error loading cleaners:', err)
      }
    },

    getBookingsForDay(date) {
      let filtered = this.bookings
      if (this.selectedPropertyId) {
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
        return 'bg-emerald-100 text-emerald-800 hover:bg-emerald-200'
      }

      const colors = {
        confirmed: 'bg-green-100 text-green-800 hover:bg-green-200',
        pending: 'bg-yellow-100 text-yellow-800 hover:bg-yellow-200',
        cancelled: 'bg-red-100 text-red-800 hover:bg-red-200',
        completed: 'bg-blue-100 text-blue-800 hover:bg-blue-200'
      }
      return colors[booking.status] || 'bg-gray-100 text-gray-800 hover:bg-gray-200'
    },

    getBookingLabel(booking) {
      if (booking.property_type === 'cleaning') {
        return `${booking.guest_name} (Faxina)`
      }
      return booking.guest_name
    },

    getStatusLabel(status) {
      const labels = {
        confirmed: 'Confirmado',
        pending: 'Pendente',
        cancelled: 'Cancelado',
        completed: 'Concluído'
      }
      return labels[status] || status
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

    openCreateModal(type = 'booking') {
      this.entryType = type
      this.editingBooking = null
      this.form = this.getEmptyForm('pending', type)
      if (this.selectedPropertyId) {
        this.form.property_id = this.selectedPropertyId
      }
      this.formErrors = {}
      this.isModalOpen = true
    },

    viewBooking(booking) {
      const type = booking.property_type === 'cleaning' ? 'cleaning' : 'booking'
      this.entryType = type
      this.editingBooking = booking
      this.form = {
        ...this.getEmptyForm('pending', type),
        ...booking,
        customer_id: booking.customer_id || '',
        property_id: booking.property_id || '',
        seller_id: booking.seller_id || '',
        property_type: booking.property_type || (type === 'cleaning' ? 'cleaning' : '')
      }
      this.isModalOpen = true
    },

    editBooking(booking) {
      const type = booking.property_type === 'cleaning' ? 'cleaning' : 'booking'
      this.entryType = type
      this.editingBooking = booking
      this.form = {
        ...this.getEmptyForm('pending', type),
        ...booking,
        customer_id: booking.customer_id || '',
        property_id: booking.property_id || '',
        seller_id: booking.seller_id || '',
        property_type: booking.property_type || (type === 'cleaning' ? 'cleaning' : '')
      }
      this.formErrors = {}
      this.isModalOpen = true
    },

    closeModal() {
      this.isModalOpen = false
      this.editingBooking = null
      this.form = this.getEmptyForm()
      this.entryType = 'booking'
      this.formErrors = {}
    },

    async saveBooking() {
      this.saving = true
      this.formErrors = {}

      try {
        const token = localStorage.getItem('token')
        const headers = { Authorization: `Bearer ${token}` }
        const isCleaning = this.entryType === 'cleaning'
        
        let selectedPerson
        if (isCleaning) {
          selectedPerson = this.cleaners.find(c => String(c.id) === String(this.form.customer_id))
        } else {
          selectedPerson = this.customers.find(c => String(c.id) === String(this.form.customer_id))
        }
        
        const selectedProperty = this.properties.find(p => String(p.id) === String(this.form.property_id))
        const payload = {
          ...this.form,
          guest_name: selectedPerson ? selectedPerson.name : this.form.guest_name,
          guest_email: selectedPerson && selectedPerson.email ? selectedPerson.email : this.form.guest_email,
          property_name: selectedProperty ? selectedProperty.name : this.form.property_name,
          property_type: isCleaning ? 'cleaning' : (this.form.property_type || ''),
          total_price: this.form.final_amount || this.form.total_price
        }

        if (this.editingBooking) {
          await axios.put(`/api/v1/stays/${this.editingBooking.id}`, 
            { stay: payload },
            { headers }
          )
        } else {
          await axios.post('/api/v1/stays',
            { stay: payload },
            { headers }
          )
        }

        this.closeModal()
        this.loadBookings()
      } catch (err) {
        this.formErrors.general = err.response?.data?.errors?.join(', ') || 'Erro ao salvar locação'
      } finally {
        this.saving = false
      }
    },

    confirmDelete(booking) {
      this.deleteConfirmBooking = booking
    },

    handleCustomerChange(event) {
      if (event.target.value === 'new') {
        this.openQuickCustomerModal()
        this.form.customer_id = ''
      }
    },

    handleCleanerChange(event) {
      if (event.target.value === 'new') {
        this.openQuickCleanerModal()
        this.form.customer_id = ''
      }
    },

    openQuickCustomerModal() {
      this.quickCustomerForm = {
        name: '',
        email: '',
        phone: '',
        cpf: '',
        rg: '',
        profession: '',
        marital_status: '',
        zip: '',
        address: '',
        number: '',
        neighborhood: '',
        city: '',
        state: '',
        note: '',
        blocked: false,
        type: 'Customer'
      }
      this.quickCustomerErrors = {}
      this.isQuickCustomerModalOpen = true
    },

    closeQuickCustomerModal() {
      this.isQuickCustomerModalOpen = false
      this.quickCustomerForm = {
        name: '',
        email: '',
        phone: '',
        cpf: '',
        rg: '',
        profession: '',
        marital_status: '',
        zip: '',
        address: '',
        number: '',
        neighborhood: '',
        city: '',
        state: '',
        note: '',
        blocked: false,
        type: 'Customer'
      }
      this.quickCustomerErrors = {}
    },

    applyPhoneMask(event) {
      let value = event.target.value.replace(/\D/g, '')
      let formattedValue = ''
      
      if (value.length <= 10) {
        if (value.length > 6) {
          formattedValue = `(${value.slice(0, 2)}) ${value.slice(2, 6)}-${value.slice(6, 10)}`
        } else if (value.length > 2) {
          formattedValue = `(${value.slice(0, 2)}) ${value.slice(2, 6)}`
        } else if (value.length > 0) {
          formattedValue = `(${value.slice(0, 2)}`
        }
      } else {
        formattedValue = `(${value.slice(0, 2)}) ${value.slice(2, 7)}-${value.slice(7, 11)}`
      }
      
      event.target.value = formattedValue
      this.quickCustomerForm.phone = formattedValue
    },

    applyCpfMask(event) {
      let value = event.target.value.replace(/\D/g, '')
      let formattedValue = ''
      
      if (value.length > 9) {
        formattedValue = `${value.slice(0, 3)}.${value.slice(3, 6)}.${value.slice(6, 9)}-${value.slice(9, 11)}`
      } else if (value.length > 6) {
        formattedValue = `${value.slice(0, 3)}.${value.slice(3, 6)}.${value.slice(6, 9)}`
      } else if (value.length > 3) {
        formattedValue = `${value.slice(0, 3)}.${value.slice(3, 6)}`
      } else {
        formattedValue = value
      }
      
      event.target.value = formattedValue
      this.quickCustomerForm.cpf = formattedValue
    },

    applyRgMask(event) {
      let value = event.target.value.replace(/\D/g, '')
      let formattedValue = ''
      
      if (value.length > 8) {
        formattedValue = `${value.slice(0, 2)}.${value.slice(2, 5)}.${value.slice(5, 8)}-${value.slice(8, 9)}`
      } else if (value.length > 5) {
        formattedValue = `${value.slice(0, 2)}.${value.slice(2, 5)}.${value.slice(5)}`
      } else if (value.length > 2) {
        formattedValue = `${value.slice(0, 2)}.${value.slice(2)}`
      } else {
        formattedValue = value
      }
      
      event.target.value = formattedValue
      this.quickCustomerForm.rg = formattedValue
    },

    applyZipMask(event) {
      let value = event.target.value.replace(/\D/g, '')
      let formattedValue = ''
      
      if (value.length > 5) {
        formattedValue = `${value.slice(0, 5)}-${value.slice(5, 8)}`
      } else {
        formattedValue = value
      }
      
      event.target.value = formattedValue
      this.quickCustomerForm.zip = formattedValue

      if (value.length === 8) {
        this.fetchAddressByCep(value)
      }
    },

    async fetchAddressByCep(cep) {
      try {
        const response = await fetch(`https://viacep.com.br/ws/${cep}/json/`)
        const data = await response.json()
        
        if (data.logradouro) {
          this.quickCustomerForm.address = data.logradouro
          this.quickCustomerForm.neighborhood = data.bairro
          this.quickCustomerForm.city = data.localidade
          this.quickCustomerForm.state = data.uf
        }
      } catch (error) {
        console.error('Erro ao buscar CEP:', error)
      }
    },

    async saveQuickCustomer() {
      this.savingQuickCustomer = true
      this.quickCustomerErrors = {}

      try {
        const token = localStorage.getItem('token')
        const headers = { Authorization: `Bearer ${token}` }
        const response = await axios.post('/api/v1/people',
          { person: this.quickCustomerForm },
          { headers }
        )

        await this.loadCustomers()
        this.form.customer_id = response.data.id
        this.closeQuickCustomerModal()
      } catch (err) {
        this.quickCustomerErrors.general = err.response?.data?.errors?.join(', ') || 'Erro ao criar hóspede'
      } finally {
        this.savingQuickCustomer = false
      }
    },

    openQuickCleanerModal() {
      this.quickCleanerForm = {
        name: '',
        email: '',
        phone: '',
        cpf: '',
        rg: '',
        profession: '',
        marital_status: '',
        zip: '',
        address: '',
        number: '',
        neighborhood: '',
        city: '',
        state: '',
        note: '',
        blocked: false,
        type: 'Cleaner'
      }
      this.quickCleanerErrors = {}
      this.isQuickCleanerModalOpen = true
    },

    closeQuickCleanerModal() {
      this.isQuickCleanerModalOpen = false
      this.quickCleanerForm = {
        name: '',
        email: '',
        phone: '',
        cpf: '',
        rg: '',
        profession: '',
        marital_status: '',
        zip: '',
        address: '',
        number: '',
        neighborhood: '',
        city: '',
        state: '',
        note: '',
        blocked: false,
        type: 'Cleaner'
      }
      this.quickCleanerErrors = {}
    },

    applyPhoneMaskCleaner(event) {
      let value = event.target.value.replace(/\D/g, '')
      let formattedValue = ''
      
      if (value.length <= 10) {
        if (value.length > 6) {
          formattedValue = `(${value.slice(0, 2)}) ${value.slice(2, 6)}-${value.slice(6, 10)}`
        } else if (value.length > 2) {
          formattedValue = `(${value.slice(0, 2)}) ${value.slice(2, 6)}`
        } else if (value.length > 0) {
          formattedValue = `(${value.slice(0, 2)}`
        }
      } else {
        formattedValue = `(${value.slice(0, 2)}) ${value.slice(2, 7)}-${value.slice(7, 11)}`
      }
      
      event.target.value = formattedValue
      this.quickCleanerForm.phone = formattedValue
    },

    applyCpfMaskCleaner(event) {
      let value = event.target.value.replace(/\D/g, '')
      let formattedValue = ''
      
      if (value.length > 9) {
        formattedValue = `${value.slice(0, 3)}.${value.slice(3, 6)}.${value.slice(6, 9)}-${value.slice(9, 11)}`
      } else if (value.length > 6) {
        formattedValue = `${value.slice(0, 3)}.${value.slice(3, 6)}.${value.slice(6, 9)}`
      } else if (value.length > 3) {
        formattedValue = `${value.slice(0, 3)}.${value.slice(3, 6)}`
      } else {
        formattedValue = value
      }
      
      event.target.value = formattedValue
      this.quickCleanerForm.cpf = formattedValue
    },

    applyRgMaskCleaner(event) {
      let value = event.target.value.replace(/\D/g, '')
      let formattedValue = ''
      
      if (value.length > 8) {
        formattedValue = `${value.slice(0, 2)}.${value.slice(2, 5)}.${value.slice(5, 8)}-${value.slice(8, 9)}`
      } else if (value.length > 5) {
        formattedValue = `${value.slice(0, 2)}.${value.slice(2, 5)}.${value.slice(5)}`
      } else if (value.length > 2) {
        formattedValue = `${value.slice(0, 2)}.${value.slice(2)}`
      } else {
        formattedValue = value
      }
      
      event.target.value = formattedValue
      this.quickCleanerForm.rg = formattedValue
    },

    applyZipMaskCleaner(event) {
      let value = event.target.value.replace(/\D/g, '')
      let formattedValue = ''
      
      if (value.length > 5) {
        formattedValue = `${value.slice(0, 5)}-${value.slice(5, 8)}`
      } else {
        formattedValue = value
      }
      
      event.target.value = formattedValue
      this.quickCleanerForm.zip = formattedValue

      if (value.length === 8) {
        this.fetchAddressByCepCleaner(value)
      }
    },

    async fetchAddressByCepCleaner(cep) {
      try {
        const response = await fetch(`https://viacep.com.br/ws/${cep}/json/`)
        const data = await response.json()
        
        if (data.logradouro) {
          this.quickCleanerForm.address = data.logradouro
          this.quickCleanerForm.neighborhood = data.bairro
          this.quickCleanerForm.city = data.localidade
          this.quickCleanerForm.state = data.uf
        }
      } catch (error) {
        console.error('Erro ao buscar CEP:', error)
      }
    },

    async saveQuickCleaner() {
      this.savingQuickCleaner = true
      this.quickCleanerErrors = {}

      try {
        const token = localStorage.getItem('token')
        const headers = { Authorization: `Bearer ${token}` }
        const response = await axios.post('/api/v1/people',
          { person: this.quickCleanerForm },
          { headers }
        )

        await this.loadCleaners()
        this.form.customer_id = response.data.id
        this.closeQuickCleanerModal()
      } catch (err) {
        this.quickCleanerErrors.general = err.response?.data?.errors?.join(', ') || 'Erro ao criar faxineira'
      } finally {
        this.savingQuickCleaner = false
      }
    },

    async deleteBooking() {
      this.deleting = true

      try {
        const token = localStorage.getItem('token')
        await axios.delete(`/api/v1/stays/${this.deleteConfirmBooking.id}`, {
          headers: { Authorization: `Bearer ${token}` }
        })

        this.deleteConfirmBooking = null
        this.loadBookings()
      } catch (err) {
        console.error('Error deleting booking:', err)
        this.deleteConfirmBooking = null
      } finally {
        this.deleting = false
      }
    }
  }
}
</script>
