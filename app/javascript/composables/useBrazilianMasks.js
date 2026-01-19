/**
 * Composable for Brazilian input masks
 * Provides reusable mask functions for CPF, RG, phone, and CEP
 */

export function useBrazilianMasks() {
  /**
   * Apply phone mask: (00) 00000-0000 or (00) 0000-0000
   */
  const applyPhoneMask = (value) => {
    const digits = String(value).replace(/\D/g, '')
    
    if (digits.length <= 10) {
      // Formato: (00) 0000-0000
      if (digits.length > 6) {
        return `(${digits.slice(0, 2)}) ${digits.slice(2, 6)}-${digits.slice(6, 10)}`
      } else if (digits.length > 2) {
        return `(${digits.slice(0, 2)}) ${digits.slice(2, 6)}`
      } else if (digits.length > 0) {
        return `(${digits.slice(0, 2)}`
      }
    } else {
      // Formato: (00) 00000-0000
      return `(${digits.slice(0, 2)}) ${digits.slice(2, 7)}-${digits.slice(7, 11)}`
    }
    
    return ''
  }

  /**
   * Apply CPF mask: 000.000.000-00
   */
  const applyCpfMask = (value) => {
    const digits = String(value).replace(/\D/g, '')
    
    if (digits.length > 9) {
      return `${digits.slice(0, 3)}.${digits.slice(3, 6)}.${digits.slice(6, 9)}-${digits.slice(9, 11)}`
    } else if (digits.length > 6) {
      return `${digits.slice(0, 3)}.${digits.slice(3, 6)}.${digits.slice(6, 9)}`
    } else if (digits.length > 3) {
      return `${digits.slice(0, 3)}.${digits.slice(3, 6)}`
    }
    
    return digits
  }

  /**
   * Apply RG mask: 00.000.000-0
   */
  const applyRgMask = (value) => {
    const digits = String(value).replace(/\D/g, '')
    
    if (digits.length > 8) {
      return `${digits.slice(0, 2)}.${digits.slice(2, 5)}.${digits.slice(5, 8)}-${digits.slice(8, 9)}`
    } else if (digits.length > 5) {
      return `${digits.slice(0, 2)}.${digits.slice(2, 5)}.${digits.slice(5)}`
    } else if (digits.length > 2) {
      return `${digits.slice(0, 2)}.${digits.slice(2)}`
    }
    
    return digits
  }

  /**
   * Apply CEP mask: 00000-000
   */
  const applyCepMask = (value) => {
    const digits = String(value).replace(/\D/g, '')
    
    if (digits.length > 5) {
      return `${digits.slice(0, 5)}-${digits.slice(5, 8)}`
    }
    
    return digits
  }

  /**
   * Generate WhatsApp link from phone number
   */
  const getWhatsAppLink = (phone) => {
    if (!phone) return null
    const digits = String(phone).replace(/\D/g, '')
    if (digits.length !== 10 && digits.length !== 11) return null
    
    let finalDigits = digits
    if (!finalDigits.startsWith('55')) {
      finalDigits = '55' + finalDigits
    }
    
    return `https://wa.me/${finalDigits}`
  }

  /**
   * Event handler for phone input
   */
  const handlePhoneInput = (event, form) => {
    const formattedValue = applyPhoneMask(event.target.value)
    event.target.value = formattedValue
    form.phone = formattedValue
  }

  /**
   * Event handler for CPF input
   */
  const handleCpfInput = (event, form) => {
    const formattedValue = applyCpfMask(event.target.value)
    event.target.value = formattedValue
    form.cpf = formattedValue
  }

  /**
   * Event handler for RG input
   */
  const handleRgInput = (event, form) => {
    const formattedValue = applyRgMask(event.target.value)
    event.target.value = formattedValue
    form.rg = formattedValue
  }

  /**
   * Event handler for CEP input
   */
  const handleCepInput = (event, form) => {
    const formattedValue = applyCepMask(event.target.value)
    event.target.value = formattedValue
    form.zip = formattedValue
  }

  return {
    applyPhoneMask,
    applyCpfMask,
    applyRgMask,
    applyCepMask,
    getWhatsAppLink,
    handlePhoneInput,
    handleCpfInput,
    handleRgInput,
    handleCepInput
  }
}
