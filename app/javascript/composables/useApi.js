/**
 * useApi - Centralized API Call Composable
 * Provides methods for making API requests with automatic auth headers
 * Usage: const { get, post, put, delete } = useApi()
 */

import axios from 'axios'

export function useApi() {
  // Get auth token from localStorage
  const getToken = () => {
    return localStorage.getItem('token')
  }

  // Build default headers with authorization
  const getHeaders = () => {
    const token = getToken()
    return token ? { Authorization: `Bearer ${token}` } : {}
  }

  // GET request
  const get = async (endpoint) => {
    try {
      const response = await axios.get(endpoint, {
        headers: getHeaders()
      })
      return { data: response.data, error: null }
    } catch (error) {
      console.error(`GET ${endpoint} failed:`, error.message)
      return { data: null, error }
    }
  }

  // POST request
  const post = async (endpoint, payload = {}) => {
    try {
      const response = await axios.post(endpoint, payload, {
        headers: getHeaders()
      })
      return { data: response.data, error: null }
    } catch (error) {
      console.error(`POST ${endpoint} failed:`, error.message)
      return { data: null, error }
    }
  }

  // PUT request (update)
  const put = async (endpoint, payload = {}) => {
    try {
      const response = await axios.put(endpoint, payload, {
        headers: getHeaders()
      })
      return { data: response.data, error: null }
    } catch (error) {
      console.error(`PUT ${endpoint} failed:`, error.message)
      return { data: null, error }
    }
  }

  // DELETE request
  const remove = async (endpoint) => {
    try {
      const response = await axios.delete(endpoint, {
        headers: getHeaders()
      })
      return { data: response.data, error: null }
    } catch (error) {
      console.error(`DELETE ${endpoint} failed:`, error.message)
      return { data: null, error }
    }
  }

  // Convenience methods for common endpoints
  const getPeople = async (type = null) => {
    const url = type ? `/api/v1/people?type=${type}` : '/api/v1/people'
    return get(url)
  }

  const getStays = async () => {
    return get('/api/v1/stays')
  }

  const getProperties = async () => {
    return get('/api/v1/properties')
  }

  const savePerson = async (person) => {
    return post('/api/v1/people', { person })
  }

  const saveStay = async (stay) => {
    return post('/api/v1/stays', { stay })
  }

  const updateStay = async (id, stay) => {
    return put(`/api/v1/stays/${id}`, { stay })
  }

  const deleteStay = async (id) => {
    return remove(`/api/v1/stays/${id}`)
  }

  return {
    // Core methods
    get,
    post,
    put,
    delete: remove,
    getToken,
    getHeaders,
    // Convenience methods
    getPeople,
    getStays,
    getProperties,
    savePerson,
    saveStay,
    updateStay,
    deleteStay
  }
}
