/**
 * Composable for address lookup via ViaCEP API
 * Provides function to fetch address data from Brazilian postal code
 */

export function useViaCep() {
  /**
   * Fetch address data from ViaCEP API
   * @param {string} cep - Brazilian postal code
   * @returns {Promise<Object|null>} Address data or null if not found
   */
  const fetchAddressByCep = async (cep) => {
    const digits = String(cep).replace(/\D/g, '')
    
    if (digits.length !== 8) {
      return null
    }

    try {
      const response = await fetch(`https://viacep.com.br/ws/${digits}/json/`)
      const data = await response.json()
      
      if (data.erro) {
        return null
      }
      
      return {
        address: data.logradouro || '',
        neighborhood: data.bairro || '',
        city: data.localidade || '',
        state: data.uf || ''
      }
    } catch (error) {
      console.error('Erro ao buscar CEP:', error)
      return null
    }
  }

  /**
   * Event handler for CEP input with auto-fill
   * Updates form refs when address is found
   */
  const handleCepLookup = async (event, refs, form) => {
    const cepInput = event.target
    const value = cepInput.value.replace(/\D/g, '')
    
    // Format CEP
    let formattedValue = ''
    if (value.length > 5) {
      formattedValue = `${value.slice(0, 5)}-${value.slice(5, 8)}`
    } else {
      formattedValue = value
    }
    cepInput.value = formattedValue
    
    // If CEP is complete, fetch address data
    if (value.length === 8) {
      const addressData = await fetchAddressByCep(value)
      
      if (addressData) {
        // Update form using refs
        if (refs.addressInput && addressData.address) {
          refs.addressInput.value = addressData.address
          refs.addressInput.dispatchEvent(new Event('input', { bubbles: true }))
        }
        
        if (refs.neighborhoodInput && addressData.neighborhood) {
          refs.neighborhoodInput.value = addressData.neighborhood
          refs.neighborhoodInput.dispatchEvent(new Event('input', { bubbles: true }))
        }
        
        if (refs.cityInput && addressData.city) {
          refs.cityInput.value = addressData.city
          refs.cityInput.dispatchEvent(new Event('input', { bubbles: true }))
        }
        
        // State is handled via v-model in SelectWithFilter
        if (refs.stateInput && addressData.state) {
          refs.stateInput.$emit('update:modelValue', addressData.state)
        }
      }
    }
  }

  return {
    fetchAddressByCep,
    handleCepLookup
  }
}
