<template>
  <div class="bg-white rounded-lg shadow-md p-6">
    <h3 class="text-lg font-bold text-gray-900 mb-6">Selecionar Período</h3>
    
    <!-- Calendar Navigation -->
    <div class="flex justify-between items-center mb-6">
      <button 
        @click="previousMonth" 
        class="p-2 hover:bg-gray-100 rounded-lg transition-colors"
        aria-label="Mês anterior"
      >
        <i class="fas fa-chevron-left text-gray-600"></i>
      </button>
      
      <h4 class="text-lg font-semibold text-gray-900 min-w-[200px] text-center">
        {{ currentMonth.toLocaleDateString('pt-BR', { month: 'long', year: 'numeric' }) }}
      </h4>
      
      <button 
        @click="nextMonth" 
        class="p-2 hover:bg-gray-100 rounded-lg transition-colors"
        aria-label="Próximo mês"
      >
        <i class="fas fa-chevron-right text-gray-600"></i>
      </button>
    </div>

    <!-- Weekday Headers -->
    <div class="grid grid-cols-7 gap-2 mb-4">
      <div 
        v-for="day in weekdayHeaders" 
        :key="day"
        class="text-center font-semibold text-gray-600 text-sm py-2"
      >
        {{ day }}
      </div>
    </div>

    <!-- Calendar Days -->
    <div class="grid grid-cols-7 gap-2 mb-6">
      <button
        v-for="day in calendarDays"
        :key="`${day.dateObj.toISOString()}-${day.isCurrentMonth}`"
        :disabled="!day.isCurrentMonth || day.isUnavailable || day.isPast"
        :class="[
          'py-3 rounded-lg font-semibold transition-all duration-200 text-sm',
          day.isInRange && !day.isCheckIn && !day.isCheckOut
            ? 'bg-indigo-200 text-indigo-900'
            : day.isCheckIn || day.isCheckOut
            ? 'bg-indigo-600 text-white'
            : day.isCurrentMonth && !day.isUnavailable && !day.isPast
            ? 'bg-indigo-50 text-indigo-700 hover:bg-indigo-100 cursor-pointer'
            : day.isUnavailable
            ? 'bg-red-50 text-red-400 opacity-50 cursor-not-allowed'
            : day.isPast
            ? 'bg-gray-50 text-gray-400 opacity-40 cursor-not-allowed'
            : 'bg-gray-50 text-gray-400 opacity-40 cursor-not-allowed'
        ]"
        @click="selectDate(day.dateObj)"
      >
        {{ day.dateObj.getDate() }}
      </button>
    </div>

    <!-- Legend -->
    <div class="space-y-2 text-xs text-gray-600 mb-6">
      <div class="flex items-center gap-2">
        <div class="w-4 h-4 rounded bg-indigo-100"></div>
        <span>Disponível</span>
      </div>
      <div class="flex items-center gap-2">
        <div class="w-4 h-4 rounded bg-indigo-600"></div>
        <span>Check-in / Check-out</span>
      </div>
      <div class="flex items-center gap-2">
        <div class="w-4 h-4 rounded bg-indigo-200"></div>
        <span>Período selecionado</span>
      </div>
      <div class="flex items-center gap-2">
        <div class="w-4 h-4 rounded bg-red-100 opacity-50"></div>
        <span>Indisponível</span>
      </div>
    </div>

    <!-- Selected Info -->
    <div v-if="checkInDate || checkOutDate" class="mt-6 p-4 bg-indigo-50 rounded-lg border border-indigo-200">
      <p class="text-sm font-semibold text-gray-700 mb-2">Período selecionado:</p>
      <p v-if="checkInDate" class="text-sm text-indigo-700">
        <i class="fas fa-sign-in-alt mr-2"></i>
        <strong>Check-in:</strong> {{ checkInDate.toLocaleDateString('pt-BR', { weekday: 'short', day: 'numeric', month: 'short', year: 'numeric' }) }}
      </p>
      <p v-if="checkOutDate" class="text-sm text-indigo-700">
        <i class="fas fa-sign-out-alt mr-2"></i>
        <strong>Check-out:</strong> {{ checkOutDate.toLocaleDateString('pt-BR', { weekday: 'short', day: 'numeric', month: 'short', year: 'numeric' }) }}
      </p>
    </div>

    <!-- Action Buttons -->
    <div v-if="checkInDate && checkOutDate" class="mt-6 flex gap-3">
      <button
        @click="confirmSelection"
        class="flex-1 bg-indigo-600 text-white font-bold py-3 rounded-lg hover:bg-indigo-700 transition-all duration-200"
      >
        <i class="fas fa-check mr-2"></i> Confirmar
      </button>
      <button
        @click="clearSelection"
        class="flex-1 bg-gray-200 text-gray-700 font-bold py-3 rounded-lg hover:bg-gray-300 transition-all duration-200"
      >
        <i class="fas fa-times mr-2"></i> Limpar
      </button>
    </div>
    <div v-else-if="checkInDate" class="mt-6 p-4 bg-yellow-50 border border-yellow-200 rounded-lg text-center">
      <p class="text-sm text-yellow-800">
        <i class="fas fa-calendar mr-2"></i>
        Selecione a data de check-out
      </p>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PropertyCalendar',
  
  props: {
    unavailableDates: {
      type: Array,
      default: () => []
    }
  },

  data() {
    return {
      currentMonth: new Date(),
      checkInDate: null,
      checkOutDate: null,
      weekdayHeaders: ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb']
    }
  },

  computed: {
    calendarDays() {
      const year = this.currentMonth.getFullYear()
      const month = this.currentMonth.getMonth()
      
      // Get first day of month and number of days
      const firstDay = new Date(year, month, 1).getDay()
      const daysInMonth = new Date(year, month + 1, 0).getDate()
      const daysInPrevMonth = new Date(year, month, 0).getDate()
      
      const days = []
      
      // Previous month days
      for (let i = firstDay - 1; i >= 0; i--) {
        days.push({
          dateObj: new Date(year, month - 1, daysInPrevMonth - i),
          isCurrentMonth: false,
          isUnavailable: false,
          isPast: false,
          isCheckIn: false,
          isCheckOut: false,
          isInRange: false
        })
      }
      
      // Current month days
      const today = new Date()
      today.setHours(0, 0, 0, 0)
      
      for (let i = 1; i <= daysInMonth; i++) {
        const dateObj = new Date(year, month, i)
        const dateStr = dateObj.toISOString().split('T')[0]
        const isPast = dateObj < today
        const isUnavailable = this.unavailableDates.includes(dateStr)
        const isCheckIn = this.checkInDate && dateObj.toDateString() === this.checkInDate.toDateString()
        const isCheckOut = this.checkOutDate && dateObj.toDateString() === this.checkOutDate.toDateString()
        
        // Check if date is in range between check-in and check-out
        let isInRange = false
        if (this.checkInDate && this.checkOutDate && !isPast && !isUnavailable) {
          isInRange = dateObj > this.checkInDate && dateObj < this.checkOutDate
        }
        
        days.push({
          dateObj,
          isCurrentMonth: true,
          isUnavailable,
          isPast,
          isCheckIn,
          isCheckOut,
          isInRange
        })
      }
      
      // Next month days
      const remainingDays = 42 - days.length // 6 rows * 7 days
      for (let i = 1; i <= remainingDays; i++) {
        days.push({
          dateObj: new Date(year, month + 1, i),
          isCurrentMonth: false,
          isUnavailable: false,
          isPast: false,
          isCheckIn: false,
          isCheckOut: false,
          isInRange: false
        })
      }
      
      return days
    }
  },

  methods: {
    previousMonth() {
      this.currentMonth = new Date(this.currentMonth.getFullYear(), this.currentMonth.getMonth() - 1)
    },

    nextMonth() {
      this.currentMonth = new Date(this.currentMonth.getFullYear(), this.currentMonth.getMonth() + 1)
    },

    selectDate(date) {
      const dateStr = date.toISOString().split('T')[0]
      const today = new Date()
      today.setHours(0, 0, 0, 0)
      const isPast = date < today
      const isUnavailable = this.unavailableDates.includes(dateStr)
      
      if (isPast || isUnavailable) return
      
      // If no check-in date, set it
      if (!this.checkInDate) {
        this.checkInDate = new Date(date)
        this.checkOutDate = null
        return
      }
      
      // If check-in is set but no check-out, set check-out
      if (!this.checkOutDate) {
        if (date <= this.checkInDate) {
          // If selected date is before check-in, reset check-in
          this.checkInDate = new Date(date)
          this.checkOutDate = null
        } else {
          // Set check-out date
          this.checkOutDate = new Date(date)
        }
        return
      }
      
      // If both are set, reset and start over
      this.checkInDate = new Date(date)
      this.checkOutDate = null
    },

    confirmSelection() {
      if (this.checkInDate && this.checkOutDate) {
        this.$emit('dates-selected', {
          checkIn: this.checkInDate.toISOString().split('T')[0],
          checkOut: this.checkOutDate.toISOString().split('T')[0]
        })
        this.clearSelection()
      }
    },

    clearSelection() {
      this.checkInDate = null
      this.checkOutDate = null
    }
  }
}
</script>

