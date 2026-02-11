<template>
  <div class="min-h-screen bg-gray-50">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div class="mb-6 flex justify-between items-center">
        <h1 class="text-3xl font-bold text-gray-900">Hospedagens</h1>
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
            <span>Nova Hospedagem</span>
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
            Para criar hospedagens, é necessário cadastrar ao menos um imóvel no sistema.
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
        <div class="mb-4 w-full md:w-80">
          <PropertySelectAsync
            v-model="selectedPropertyId"
            label="Filtrar por Imóvel"
            placeholder="Selecione um imóvel para filtrar..."
            :required="true"
          />
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

        <div class="relative">
          <!-- Overlay de loading no calendário -->
          <div v-if="loading" class="absolute inset-0 bg-white bg-opacity-75 flex items-center justify-center z-10 rounded-lg">
            <div class="flex flex-col items-center">
              <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600 mb-2"></div>
              <p class="text-sm text-gray-600">Atualizando calendário...</p>
            </div>
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
                  :title="getBookingTooltip(booking)"
                >
                  {{ getBookingLabel(booking) }}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow-sm p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">Hospedagens do Mês</h3>
        
        <div v-if="loading" class="flex flex-col items-center justify-center py-8">
          <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600 mb-3"></div>
          <p class="text-sm text-gray-600">Carregando hospedagens...</p>
        </div>

        <div v-else-if="bookings.length === 0" class="text-center py-8 text-gray-500">
          Nenhuma hospedagem neste período
        </div>

        <div v-else class="space-y-3">
          <div
            v-for="booking in sortedBookings"
            :key="booking.id"
            @click="viewBooking(booking)"
            :class="[
              'p-4 rounded-lg border-l-4 cursor-pointer hover:shadow-md transition',
              booking.type === 'Service' ? 'bg-green-50 border-green-500' : 'bg-indigo-50 border-indigo-500'
            ]"
          >
            <div class="flex justify-between items-start">
              <div class="flex-1">
                <div class="flex items-center space-x-2 mb-2">
                  <!-- Ícone e tipo -->
                  <div :class="[
                    'flex items-center justify-center w-8 h-8 rounded-full',
                    booking.type === 'Service' ? 'bg-green-200' : 'bg-indigo-200'
                  ]">
                    <svg v-if="booking.type === 'Service'" class="w-5 h-5 text-green-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                    </svg>
                    <svg v-else class="w-5 h-5 text-indigo-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
                    </svg>
                  </div>
                  
                  <div class="flex-1">
                    <div class="flex items-center gap-2">
                      <h4 class="font-semibold text-gray-900">{{ getBookingLabel(booking) }}</h4>
                      <span :class="[
                        'text-xs px-2 py-0.5 rounded-full font-medium',
                        booking.type === 'Service' ? 'bg-green-100 text-green-800 border border-green-300' : 'bg-indigo-100 text-indigo-800 border border-indigo-300'
                      ]">
                        {{ booking.type === 'Service' ? 'Serviço' : 'Hospedagem' }}
                      </span>
                    </div>
                    <p class="text-xs text-gray-500 mt-0.5">{{ booking.customer?.name || (booking.type === 'Service' ? 'Prestador' : 'Hóspede') }}</p>
                  </div>
                </div>
                
                <div class="ml-10">
                  <p class="text-sm text-gray-700 mb-2 font-medium">{{ booking.property?.name || 'Imóvel' }}</p>
                  <div class="flex items-center space-x-4 text-xs text-gray-600">
                    <span class="flex items-center gap-1">
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                      </svg>
                      {{ formatDate(booking.check_in_date) }}{{ booking.check_in_time ? ' às ' + formatTime(booking.check_in_time) : '' }}
                    </span>
                    <span class="text-gray-400">→</span>
                    <span class="flex items-center gap-1">
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                      </svg>
                      {{ formatDate(booking.check_out_date) }}{{ booking.check_out_time ? ' às ' + formatTime(booking.check_out_time) : '' }}
                    </span>
                    <span v-if="booking.total_price" class="ml-auto font-semibold text-gray-900">
                      R$ {{ parseFloat(booking.total_price).toFixed(2) }}
                    </span>
                  </div>
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
            {{ editingBooking ? (entryType === 'cleaning' ? 'Editar Serviço' : 'Editar Hospedagem') : (entryType === 'cleaning' ? 'Novo Serviço' : 'Nova Hospedagem') }}
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
                <PersonSelectAsync
                  v-model="form.customer_id"
                  :selected-person="selectedCleaner"
                  label="Prestador *"
                  role="provider"
                  @update:modelValue="handleCleanerChange"
                />
              </div>              

              <div class="grid-cols-1 md:grid-cols-2 gap-4">
                <PropertySelectAsync
                  v-model="form.property_id"
                  :selected-property="selectedFormProperty"
                  label="Imóvel *"
                  placeholder="Selecione um imóvel..."
                />
              </div>

              <div class="md:col-span-2">
                <ServiceTypeSelectAsync
                  v-model="form.service_type_id"
                  :selected-service-type="selectedFormServiceType"
                  label="Tipo de Serviço *"
                  placeholder="Selecione um tipo de serviço..."
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
                <label class="block text-sm font-medium text-gray-700 mb-1">
                  <span class="flex items-center gap-1">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                    Horário Início
                  </span>
                </label>
                <input
                  v-model="form.check_in_time"
                  type="time"
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

              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">
                  <span class="flex items-center gap-1">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                    Horário Fim
                  </span>
                </label>
                <input
                  v-model="form.check_out_time"
                  type="time"
                  class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                />
              </div>
            </div>

            <!-- Aviso para mesmo dia -->
            <div v-if="formErrors.sameDayCheckout" class="bg-yellow-50 border-l-4 border-yellow-400 p-4 rounded">
              <div class="flex">
                <div class="flex-shrink-0">
                  <svg class="h-5 w-5 text-yellow-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                  </svg>
                </div>
                <div class="ml-3">
                  <p class="text-sm text-yellow-700">{{ formErrors.sameDayCheckout }}</p>
                </div>
              </div>
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
              <label class="block text-sm font-medium text-gray-700 mb-1">Observação</label>
              <textarea
                v-model="form.description"
                rows="4"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              ></textarea>
            </div>

            <!-- Anexos (serviços) -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Anexos</label>
              <AttachmentManager
                v-model="form.attachments"
                v-model:remove-attachment-ids="form.remove_attachment_ids"
                v-model:attachments-order="form.attachments_order"
                :accepted-types="'*'"
                :enable-reorder="true"
                :enable-lightbox="true"
              />
            </div>
          </div>

          <div v-else class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <PersonSelectAsync
                v-model="form.customer_id"
                :selected-person="selectedCustomer"
                label="Hóspede *"
                role="customer"
                @update:modelValue="handleCustomerChange"
              />
            </div>

            <div>
              <PropertySelectAsync
                v-model="form.property_id"
                :selected-property="selectedFormProperty"
                label="Imóvel *"
                placeholder="Selecione um imóvel..."
              />
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
              <label class="block text-sm font-medium text-gray-700 mb-1">
                <span class="flex items-center gap-1">
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                  Horário Check-in
                </span>
              </label>
              <input
                v-model="form.check_in_time"
                type="time"
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
              <label class="block text-sm font-medium text-gray-700 mb-1">
                <span class="flex items-center gap-1">
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                  Horário Check-out
                </span>
              </label>
              <input
                v-model="form.check_out_time"
                type="time"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <!-- Aviso para mesmo dia -->
            <div v-if="formErrors.sameDayCheckout" class="md:col-span-2 bg-yellow-50 border-l-4 border-yellow-400 p-4 rounded">
              <div class="flex">
                <div class="flex-shrink-0">
                  <svg class="h-5 w-5 text-yellow-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                  </svg>
                </div>
                <div class="ml-3">
                  <p class="text-sm text-yellow-700">{{ formErrors.sameDayCheckout }}</p>
                </div>
              </div>
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
              <PersonSelectAsync
                v-model="form.seller_id"
                :selected-person="selectedSeller"
                label="Corretor"
                role="agent"
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
                v-model:attachments-order="form.attachments_order"
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
      message="Tem certeza que deseja excluir esta hospedagem? Esta ação não pode ser desfeita."
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

    <QuickServiceTypeModal
      :isOpen="quickServiceTypeModalOpen"
      @save="handleQuickServiceTypeSave"
      @close="closeQuickServiceTypeModal"
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
import PersonSelectAsync from './PersonSelectAsync.vue'
import PropertySelectAsync from './PropertySelectAsync.vue'
import ServiceTypeSelect from './ServiceTypeSelect.vue'
import ServiceTypeSelectAsync from './ServiceTypeSelectAsync.vue'
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
    PersonSelectAsync,
    PropertySelectAsync,
    ServiceTypeSelect,
    ServiceTypeSelectAsync,
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
      properties: [],
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
      weekDays: ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'],
      // Estados para armazenar os objetos selecionados
      currentCustomer: null,
      currentSeller: null
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
      if (this.selectedPropertyId !== null && this.selectedPropertyId !== undefined) {
        filtered = filtered.filter(b => {
          const bookingPropertyId = b.property?.id || b.property_id
          return String(bookingPropertyId) === String(this.selectedPropertyId)
        })
      }
      return [...filtered].sort((a, b) => {
        return new Date(a.check_in_date) - new Date(b.check_in_date)
      })
    },

    selectedCustomer() {
      // Priorizar o estado atual (quando selecionado manualmente)
      if (this.currentCustomer) return this.currentCustomer
      // Fallback para editingBooking
      if (!this.editingBooking || !this.editingBooking.customer) return null
      return this.editingBooking.customer
    },

    selectedCleaner() {
      // Priorizar o estado atual (quando selecionado manualmente)
      if (this.currentCustomer) return this.currentCustomer
      // Fallback para editingBooking
      if (!this.editingBooking || !this.editingBooking.customer) return null
      return this.editingBooking.customer
    },

    selectedSeller() {
      // Priorizar o estado atual (quando selecionado manualmente)
      if (this.currentSeller) return this.currentSeller
      // Fallback para editingBooking
      if (!this.editingBooking || !this.editingBooking.seller) return null
      return this.editingBooking.seller
    },

    selectedFormProperty() {
      if (!this.editingBooking || !this.editingBooking.property) return null
      return this.editingBooking.property
    },

    selectedFormServiceType() {
      if (!this.editingBooking || !this.editingBooking.service_type) return null
      return this.editingBooking.service_type
    },

    serviceTypeOptions() {
      return [
        { value: 'new', label: '+ Novo Tipo de Serviço' },
        ...(Array.isArray(this.serviceTypes) ? this.serviceTypes.map(st => ({ value: String(st.id), label: st.name })) : [])
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

    selectedPropertyId(newVal, oldVal) {
      // Quando o imóvel selecionado mudar, recarregar os dados
      if (newVal !== oldVal && oldVal !== undefined) {
        this.loadServicesByMonth()
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
    },

    'form.check_in_date': function(newVal) {
      this.validateSameDayCheckout()
    },

    'form.check_out_date': function(newVal) {
      this.validateSameDayCheckout()
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
        check_in_date: '',
        check_in_time: type === 'booking' ? '16:00' : '',
        check_out_date: '',
        check_out_time: type === 'booking' ? '11:00' : '',
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
        const { getProperties, getServiceTypes } = useApi()
        await Promise.all([
          this.loadServicesByMonth(),
          this.loadProperties(getProperties),
          this.loadServiceTypes(getServiceTypes)
        ])
      } finally {
        this.loading = false
      }
    },

    async loadServicesByMonth() {
      this.loading = true
      
      const startDate = new Date(this.currentYear, this.currentMonth, 1)
      const endDate = new Date(this.currentYear, this.currentMonth + 1, 0)

      const startDateString = startDate.toISOString().split('T')[0]
      const endDateString = endDate.toISOString().split('T')[0]

      try {
        const { getServices } = useApi()
        const { data, error } = await getServices(startDateString, endDateString)
        if (!error && data) {
          this.bookings = data
        }
      } catch (err) {
        console.error('Error loading bookings by month:', err)
      } finally {
        this.loading = false
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
      if (this.selectedPropertyId !== null && this.selectedPropertyId !== undefined) {
        filtered = filtered.filter(b => {
          const bookingPropertyId = b.property?.id || b.property_id
          return String(bookingPropertyId) === String(this.selectedPropertyId)
        })
      }
      
      // Normalizar a data do calendário para início do dia (00:00:00)
      const targetDate = new Date(date.getFullYear(), date.getMonth(), date.getDate())
      
      return filtered.filter(booking => {
        // Criar datas normalizadas (início do dia) para comparação
        const checkIn = new Date(booking.check_in_date + 'T00:00:00')
        const checkOut = new Date(booking.check_out_date + 'T00:00:00')
        
        // Verificar se a data do calendário está dentro do período do booking
        return targetDate >= checkIn && targetDate <= checkOut
      })
    },

    getBookingColor(booking) {
      if (booking.type === 'Service') {
        return 'bg-green-100 text-green-800 hover:bg-green-200'
      }
      return 'bg-indigo-100 text-indigo-800 hover:bg-indigo-200'
    },

    getBookingLabel(booking) {
      if (booking.type === 'Service') {
        const serviceTypeName = booking.service_type?.name || 'Serviço'
        return serviceTypeName
      }
      return `${booking.customer?.name}`
    },

    getBookingTooltip(booking) {
      const propertyName = booking.property?.name || 'Imóvel'
      let tooltip = ''
      
      if (booking.type === 'Service') {
        const serviceTypeName = booking.service_type?.name || 'Serviço'
        const providerName = booking.customer?.name || 'Prestador'
        tooltip = `${serviceTypeName} - ${providerName} - ${propertyName}`
      } else {
        const customerName = booking.customer?.name || 'Hóspede'
        tooltip = `Hospedagem - ${customerName} - ${propertyName}`
      }
      
      if (booking.check_in_time || booking.check_out_time) {
        tooltip += '\n'
        if (booking.check_in_time) {
          tooltip += `Início: ${this.formatTime(booking.check_in_time)}`
        }
        if (booking.check_out_time) {
          if (booking.check_in_time) tooltip += ' | '
          tooltip += `Fim: ${this.formatTime(booking.check_out_time)}`
        }
      }
      
      return tooltip
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
      const date = new Date(dateString + 'T00:00:00')
      return date.toLocaleDateString('pt-BR')
    },

    formatTime(timeString) {
      if (!timeString) return ''
      // timeString pode vir como "HH:MM:SS" ou "HH:MM"
      const parts = timeString.split(':')
      return `${parts[0]}:${parts[1]}`
    },

    validateSameDayCheckout() {
      // Limpar erro anterior se existir
      if (this.formErrors.sameDayCheckout) {
        delete this.formErrors.sameDayCheckout
      }

      // Se as datas forem iguais e não tiver horários, mostrar aviso
      if (this.form.check_in_date && this.form.check_out_date && 
          this.form.check_in_date === this.form.check_out_date) {
        if (!this.form.check_in_time || !this.form.check_out_time) {
          this.formErrors.sameDayCheckout = 'Atenção: Para check-in e check-out no mesmo dia, é obrigatório informar os horários'
        }
      }
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
      // Limpar estados de pessoas selecionadas
      this.currentCustomer = null
      this.currentSeller = null
      this.isModalOpen = true
    },

    viewBooking(booking) {
      const type = booking.type === 'Service' ? 'cleaning' : 'booking'
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
        customer_id: booking.customer?.id ? String(booking.customer.id) : (booking.customer_id ? String(booking.customer_id) : ''),
        property_id: booking.property?.id || booking.property_id || '',
        seller_id: booking.seller?.id ? String(booking.seller.id) : (booking.seller_id ? String(booking.seller_id) : ''),
        service_type_id: booking.service_type?.id ? String(booking.service_type.id) : (booking.service_type_id ? String(booking.service_type_id) : ''),
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
      const type = booking.type === 'Service' ? 'cleaning' : 'booking'
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
        customer_id: booking.customer?.id ? String(booking.customer.id) : (booking.customer_id ? String(booking.customer_id) : ''),
        property_id: booking.property?.id || booking.property_id || '',
        seller_id: booking.seller?.id ? String(booking.seller.id) : (booking.seller_id ? String(booking.seller_id) : ''),
        service_type_id: booking.service_type?.id ? String(booking.service_type.id) : (booking.service_type_id ? String(booking.service_type_id) : ''),
        // Formatar valores monetários para exibição
        total_due: formatMoneyValue(booking.total_due),
        deposit_amount: formatMoneyValue(booking.deposit_amount),
        final_amount: formatMoneyValue(booking.final_amount),
        total_payable: formatMoneyValue(booking.total_payable),
        total_paid: formatMoneyValue(booking.total_paid),
        // Garantir que anexos e ordem sejam carregados
        attachments: booking.attachments || [],
        attachments_order: booking.attachments_order || []
      }
      // Limpar estados para forçar uso do editingBooking
      this.currentCustomer = null
      this.currentSeller = null
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
      // Limpar estados de pessoas selecionadas
      this.currentCustomer = null
      this.currentSeller = null
      this.form = this.getEmptyForm()
      this.entryType = 'booking'
      this.formErrors = {}
    },

    buildServiceFormData() {
      const isCleaning = this.entryType === 'cleaning'
      
      // Verificar se há novos anexos (arquivos File/Blob)
      const isFile = (item) => (typeof File !== 'undefined' && item instanceof File) ||
        (typeof Blob !== 'undefined' && item instanceof Blob)
      const newFiles = (this.form.attachments || []).filter(item => isFile(item))
      const hasNewFiles = newFiles.length > 0
      const hasRemovedAttachments = this.form.remove_attachment_ids && this.form.remove_attachment_ids.length > 0
      const hasAttachmentsOrder = this.form.attachments_order && this.form.attachments_order.length > 0

      // Helper para converter IDs para números ou deixar null
      const parseId = (value) => {
        if (!value || value === '' || value === 'new') return null
        const parsed = parseInt(value, 10)
        return isNaN(parsed) ? null : parsed
      }

      // Dados do serviço/hospedagem
      const serviceData = {
        customer_id: parseId(this.form.customer_id),
        property_id: parseId(this.form.property_id),
        seller_id: parseId(this.form.seller_id),
        service_type_id: parseId(this.form.service_type_id),
        check_in_date: this.form.check_in_date,
        check_in_time: this.form.check_in_time || null,
        check_out_date: this.form.check_out_date,
        check_out_time: this.form.check_out_time || null,
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

      // Determinar o prefixo baseado no tipo
      const paramKey = isCleaning ? 'service' : 'stay'

      // Se vamos usar JSON (não FormData), adicionar arrays ao serviceData
      if (!hasNewFiles && !hasRemovedAttachments && !hasAttachmentsOrder) {
        return { useFormData: false, payload: serviceData, paramKey }
      }

      // Para JSON, incluir arrays apenas se tiverem elementos
      if (!hasNewFiles) {
        if (hasRemovedAttachments) {
          serviceData.remove_attachment_ids = this.form.remove_attachment_ids
        }
        if (hasAttachmentsOrder) {
          serviceData.attachments_order = this.form.attachments_order
        }
        return { useFormData: false, payload: serviceData, paramKey }
      }

      // Construir FormData para enviar arquivos
      const formData = new FormData()
      
      // Adicionar todos os campos do serviço/hospedagem com prefixo correto
      Object.keys(serviceData).forEach(key => {
        const value = serviceData[key]
        if (value !== null && value !== undefined && value !== '') {
          formData.append(`${paramKey}[${key}]`, value)
        }
      })

      // Adicionar novos arquivos
      newFiles.forEach((file) => {
        formData.append(`${paramKey}[attachments][]`, file, file.name)
      })

      // Adicionar IDs de anexos a remover
      if (hasRemovedAttachments) {
        this.form.remove_attachment_ids.forEach(id => {
          formData.append(`${paramKey}[remove_attachment_ids][]`, id)
        })
      }

      // Adicionar ordem dos anexos
      if (this.form.attachments_order && this.form.attachments_order.length > 0) {
        this.form.attachments_order.forEach(id => {
          formData.append(`${paramKey}[attachments_order][]`, id)
        })
      }

      return { useFormData: true, payload: formData, paramKey }
    },

    async saveBooking() {
      this.saving = true
      this.formErrors = {}

      // Validar horários se check-in e check-out forem no mesmo dia
      if (this.form.check_in_date === this.form.check_out_date) {
        if (!this.form.check_in_time || !this.form.check_out_time) {
          this.formErrors.general = 'Para check-in e check-out no mesmo dia, é necessário definir os horários'
          this.saving = false
          return
        }

        if (this.form.check_out_time <= this.form.check_in_time) {
          this.formErrors.general = 'O horário de saída deve ser posterior ao horário de entrada quando no mesmo dia'
          this.saving = false
          return
        }
      }

      try {
        const { post, put, postFormData, putFormData } = useApi()
        const { useFormData, payload, paramKey } = this.buildServiceFormData()
        
        // Determinar o tipo de endpoint baseado no tipo de entrada
        const isService = this.entryType === 'cleaning'
        const endpoint = isService ? '/api/v1/services' : '/api/v1/stays'

        let result
        if (this.editingBooking) {
          if (useFormData) {
            result = await putFormData(`${endpoint}/${this.editingBooking.id}`, payload)
          } else {
            result = await put(`${endpoint}/${this.editingBooking.id}`, { [paramKey]: payload })
          }
        } else {
          if (useFormData) {
            result = await postFormData(endpoint, payload)
          } else {
            result = await post(endpoint, { [paramKey]: payload })
          }
        }

        if (result.error) {
          this.formErrors.general = result.error.response?.data?.errors?.join(', ') || 'Erro ao salvar hospedagem'
          return
        }

        this.closeModal()
        this.loadServicesByMonth()
      } catch (err) {
        this.formErrors.general = err.response?.data?.errors?.join(', ') || 'Erro ao salvar hospedagem'
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
        this.currentCustomer = null
      } else {
        // Buscar o objeto completo da pessoa selecionada
        this.fetchPersonById(value, 'customer')
      }
    },

    handleCleanerChange(value) {
      if (value === 'new') {
        this.quickPersonModalOpen = { isOpen: true, type: 'Cleaner' }
        this.form.customer_id = ''
        this.currentCustomer = null
      } else {
        // Buscar o objeto completo da pessoa selecionada
        this.fetchPersonById(value, 'provider')
      }
    },

    handleSellerChange(value) {
      if (value === 'new') {
        this.quickPersonModalOpen = { isOpen: true, type: 'Seller' }
        this.form.seller_id = ''
        this.currentSeller = null
      } else {
        // Buscar o objeto completo da pessoa selecionada
        this.fetchPersonById(value, 'agent')
      }
    },

    async fetchPersonById(personId, role) {
      if (!personId) return
      
      try {
        const userToken = localStorage.getItem('userToken')
        const tenantToken = localStorage.getItem('tenantToken')
        
        const response = await axios.get(`/api/v1/people/${personId}`, {
          headers: { 
            Authorization: `Bearer ${userToken}`, 
            'Tenant-Authorization': `Bearer ${tenantToken}` 
          }
        })
        
        if (response.data) {
          // Atualizar o estado correto baseado no role
          if (role === 'customer' || role === 'provider') {
            this.currentCustomer = response.data
          } else if (role === 'agent') {
            this.currentSeller = response.data
          }
        }
      } catch (err) {
        console.error('Error fetching person:', err)
      }
    },

    handleQuickPersonSave(person) {
      // Apenas atualizar o ID do formulário, o PersonSelectAsync vai lidar com a atualização
      if (this.quickPersonModalOpen.type === 'Customer') {
        this.form.customer_id = String(person.id)
      } else if (this.quickPersonModalOpen.type === 'Cleaner') {
        this.form.customer_id = String(person.id)
      } else if (this.quickPersonModalOpen.type === 'Seller') {
        this.form.seller_id = String(person.id)
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
      // Atualizar o ID e forçar recarregamento
      this.$nextTick(() => {
        this.form.service_type_id = String(serviceType.id)
        // Força o recarregamento dos tipos de serviço
        this.loadServiceTypes(useApi().getServiceTypes)
      })
      this.closeQuickServiceTypeModal()
    },

    closeQuickServiceTypeModal() {
      this.quickServiceTypeModalOpen = false
    },

    async deleteBooking() {
      this.deleting = true

      try {
        const { delete: deleteApi } = useApi()
        const isService = this.deleteConfirmBooking.type === 'Service'
        const endpoint = isService ? '/api/v1/services' : '/api/v1/stays'
        const { error } = await deleteApi(`${endpoint}/${this.deleteConfirmBooking.id}`)

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
      this.formErrors = {} // Limpar erros anteriores
      
      try {
        const { getHeaders } = useApi()
        const isService = this.editingBooking.type === 'Service'
        const endpoint = isService ? '/api/v1/services' : '/api/v1/stays'
        const requestUrl = `${window.location.origin}${endpoint}/${this.editingBooking.id}/contract`
        const response = await axios.get(requestUrl, {
          headers: getHeaders(),
          responseType: 'blob'
        })

        // Verificar se a resposta é JSON (erro) ou blob (sucesso)
        if (response.data.type === 'application/json') {
          // É um erro JSON
          const text = await response.data.text()
          const errorData = JSON.parse(text)
          
          // Mostrar mensagem de erro formatada
          if (errorData.missing_fields && errorData.missing_fields.length > 0) {
            this.formErrors.general = `${errorData.error}`
          } else {
            this.formErrors.general = errorData.error || 'Não foi possível exportar o contrato.'
          }
          return
        }

        // Sucesso - fazer download do arquivo
        const blob = new Blob([response.data], { type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' })
        const blobUrl = window.URL.createObjectURL(blob)
        const link = document.createElement('a')
        const name = (this.editingBooking.customer?.name || 'documento').replace(/[\\/:*?"<>|]/g, '')

        link.href = blobUrl
        link.setAttribute('download', `Contrato-${name}.docx`)
        document.body.appendChild(link)
        link.click()
        link.remove()
        window.URL.revokeObjectURL(blobUrl)
      } catch (err) {
        console.error('Error exporting contract:', err)
        
        // Tentar extrair mensagem de erro do backend
        if (err.response && err.response.data) {
          try {
            // Se vier como blob, tentar ler como texto
            if (err.response.data instanceof Blob) {
              const text = await err.response.data.text()
              const errorData = JSON.parse(text)
              
              if (errorData.missing_fields && errorData.missing_fields.length > 0) {
                this.formErrors.general = `${errorData.error}`
              } else {
                this.formErrors.general = errorData.error || 'Não foi possível exportar o contrato.'
              }
            } else {
              this.formErrors.general = err.response.data.error || 'Não foi possível exportar o contrato.'
            }
          } catch (parseError) {
            this.formErrors.general = 'Não foi possível exportar o contrato. Verifique se todos os dados necessários estão preenchidos.'
          }
        } else {
          this.formErrors.general = 'Não foi possível exportar o contrato agora.'
        }
      } finally {
        this.contractDownloading = false
      }
    }
  }
}
</script>
