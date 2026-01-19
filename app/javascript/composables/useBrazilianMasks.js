export function useBrazilianMasks() {
  const applyPhoneMask = (value) => {
    const digits = String(value).replace(/\D/g, '')
    
    if (digits.length <= 10) {
      if (digits.length > 6) {
        return `(${digits.slice(0, 2)}) ${digits.slice(2, 6)}-${digits.slice(6, 10)}`
      } else if (digits.length > 2) {
        return `(${digits.slice(0, 2)}) ${digits.slice(2, 6)}`
      } else if (digits.length > 0) {
        return `(${digits.slice(0, 2)}`
      }
    } else {
      return `(${digits.slice(0, 2)}) ${digits.slice(2, 7)}-${digits.slice(7, 11)}`
    }
    
    return ''
  }

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

  const applyCepMask = (value) => {
    const digits = String(value).replace(/\D/g, '')
    
    if (digits.length > 5) {
      return `${digits.slice(0, 5)}-${digits.slice(5, 8)}`
    }
    
    return digits
  }

  const applyCurrencyMask = (value) => {
    const stringValue = String(value || '')
    const clean = stringValue.replace(/\D/g, '')
    
    if (!clean) return ''
    
    const adjusted = clean.length === 1 ? '0' + clean : clean
    const integerPart = adjusted.slice(0, -2) || '0'
    const decimalPart = adjusted.slice(-2)
    const number = parseInt(integerPart) + parseInt(decimalPart) / 100
    
    return number.toLocaleString('pt-BR', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    })
  }

  const parseCurrencyToNumber = (value) => {
    if (typeof value === 'number') return value
    const stringValue = String(value || '0')
    const clean = stringValue.replace(/\./g, '').replace(',', '.')
    return parseFloat(clean) || 0
  }

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

  const handlePhoneInput = (event, form) => {
    const formattedValue = applyPhoneMask(event.target.value)
    event.target.value = formattedValue
    form.phone = formattedValue
  }

  const handleCpfInput = (event, form) => {
    const formattedValue = applyCpfMask(event.target.value)
    event.target.value = formattedValue
    form.cpf = formattedValue
  }

  const handleRgInput = (event, form) => {
    const formattedValue = applyRgMask(event.target.value)
    event.target.value = formattedValue
    form.rg = formattedValue
  }

  const handleCepInput = (event, form) => {
    const formattedValue = applyCepMask(event.target.value)
    event.target.value = formattedValue
    form.zip = formattedValue
  }

  const handlePhoneMaskInput = (event) => {
    event.target.value = applyPhoneMask(event.target.value)
  }

  const handleCpfMaskInput = (event) => {
    event.target.value = applyCpfMask(event.target.value)
  }

  const handleRgMaskInput = (event) => {
    event.target.value = applyRgMask(event.target.value)
  }

  const handleZipMaskInput = (event) => {
    event.target.value = applyCepMask(event.target.value)
  }

  const handleCurrencyMaskInput = (event) => {
    event.target.value = applyCurrencyMask(event.target.value)
  }

  return {
    applyPhoneMask,
    applyCpfMask,
    applyRgMask,
    applyCepMask,
    applyCurrencyMask,
    parseCurrencyToNumber,
    getWhatsAppLink,
    handlePhoneInput,
    handleCpfInput,
    handleRgInput,
    handleCepInput,
    handlePhoneMaskInput,
    handleCpfMaskInput,
    handleRgMaskInput,
    handleZipMaskInput,
    handleCurrencyMaskInput
  }
}
