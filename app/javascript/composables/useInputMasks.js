export function useInputMasks() {
  const applyPhoneMask = (value) => {
    let clean = value.replace(/\D/g, '')
    let formatted = ''
    
    if (clean.length <= 10) {
      if (clean.length > 6) {
        formatted = `(${clean.slice(0, 2)}) ${clean.slice(2, 6)}-${clean.slice(6, 10)}`
      } else if (clean.length > 2) {
        formatted = `(${clean.slice(0, 2)}) ${clean.slice(2, 6)}`
      } else if (clean.length > 0) {
        formatted = `(${clean.slice(0, 2)}`
      }
    } else {
      formatted = `(${clean.slice(0, 2)}) ${clean.slice(2, 7)}-${clean.slice(7, 11)}`
    }
    
    return formatted
  }

  const applyCpfMask = (value) => {
    let clean = value.replace(/\D/g, '')
    let formatted = ''
    
    if (clean.length > 9) {
      formatted = `${clean.slice(0, 3)}.${clean.slice(3, 6)}.${clean.slice(6, 9)}-${clean.slice(9, 11)}`
    } else if (clean.length > 6) {
      formatted = `${clean.slice(0, 3)}.${clean.slice(3, 6)}.${clean.slice(6, 9)}`
    } else if (clean.length > 3) {
      formatted = `${clean.slice(0, 3)}.${clean.slice(3, 6)}`
    } else {
      formatted = clean
    }
    
    return formatted
  }

  const applyRgMask = (value) => {
    let clean = value.replace(/\D/g, '')
    let formatted = ''
    
    if (clean.length > 8) {
      formatted = `${clean.slice(0, 2)}.${clean.slice(2, 5)}.${clean.slice(5, 8)}-${clean.slice(8, 9)}`
    } else if (clean.length > 5) {
      formatted = `${clean.slice(0, 2)}.${clean.slice(2, 5)}.${clean.slice(5)}`
    } else if (clean.length > 2) {
      formatted = `${clean.slice(0, 2)}.${clean.slice(2)}`
    } else {
      formatted = clean
    }
    
    return formatted
  }

  const applyZipMask = (value) => {
    let clean = value.replace(/\D/g, '')
    let formatted = ''
    
    if (clean.length > 5) {
      formatted = `${clean.slice(0, 5)}-${clean.slice(5, 8)}`
    } else {
      formatted = clean
    }
    
    return formatted
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
    event.target.value = applyZipMask(event.target.value)
  }

  const fetchAddressByCep = async (cep, form) => {
    try {
      const response = await fetch(`https://viacep.com.br/ws/${cep}/json/`)
      const data = await response.json()
      
      if (data.logradouro) {
        form.address = data.logradouro
        form.neighborhood = data.bairro
        form.city = data.localidade
        form.state = data.uf
      }
    } catch (error) {
      console.error('Erro ao buscar CEP:', error)
    }
  }

  return {
    applyPhoneMask,
    applyCpfMask,
    applyRgMask,
    applyZipMask,
    handlePhoneMaskInput,
    handleCpfMaskInput,
    handleRgMaskInput,
    handleZipMaskInput,
    fetchAddressByCep
  }
}
