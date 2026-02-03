import { useBrazilianMasks } from './useBrazilianMasks.js'

export function useInputMasks() {
  const {
    applyPhoneMask,
    applyDocumentMask,
    applyCpfMask,
    applyRgMask,
    applyCepMask,
    applyCurrencyMask,
    parseCurrencyToNumber,
    handlePhoneMaskInput,
    handleDocumentMaskInput,
    handleCpfMaskInput,
    handleRgMaskInput,
    handleZipMaskInput,
    handleCurrencyMaskInput
  } = useBrazilianMasks()

  return {
    applyPhoneMask,
    applyDocumentMask,
    applyCpfMask,
    applyRgMask,
    applyZipMask: applyCepMask,
    applyCurrencyMask,
    parseCurrencyToNumber,
    handlePhoneMaskInput,
    handleDocumentMaskInput,
    handleCpfMaskInput,
    handleRgMaskInput,
    handleZipMaskInput,
    handleCurrencyMaskInput,
    fetchAddressByCep: async (cep, form) => {
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
  }
}
