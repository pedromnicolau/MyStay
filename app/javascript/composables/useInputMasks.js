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

  const applyCurrencyMask = (value) => {
    const stringValue = String(value || '')
    
    // Remove tudo exceto números
    let clean = stringValue.replace(/\D/g, '')
    
    // Se estiver vazio, retorna vazio
    if (!clean) return ''
    
    // Se tem apenas 1 dígito, adiciona 0 à esquerda (ex: 5 vira 05 para exibir como 0,05)
    if (clean.length === 1) clean = '0' + clean
    
    // Os últimos 2 dígitos são centavos
    // Exemplo: "123456" vira "1234,56"
    const integerPart = clean.slice(0, -2) || '0'
    const decimalPart = clean.slice(-2)
    
    // Converte a parte inteira para número (para remover zeros à esquerda)
    let number = parseInt(integerPart) + parseInt(decimalPart) / 100
    
    // Formata para pt-BR com 2 casas decimais
    return number.toLocaleString('pt-BR', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    })
  }

  const parseCurrencyToNumber = (value) => {
    // Se já for número, retorna
    if (typeof value === 'number') return value
    
    // Converte para string
    const stringValue = String(value || '0')
    
    // Remove pontos (separadores de milhar) e substitui vírgula por ponto
    const clean = stringValue.replace(/\./g, '').replace(',', '.')
    return parseFloat(clean) || 0
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

  const handleCurrencyMaskInput = (event) => {
    event.target.value = applyCurrencyMask(event.target.value)
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
    applyCurrencyMask,
    parseCurrencyToNumber,
    handlePhoneMaskInput,
    handleCpfMaskInput,
    handleRgMaskInput,
    handleZipMaskInput,
    handleCurrencyMaskInput,
    fetchAddressByCep
  }
}
