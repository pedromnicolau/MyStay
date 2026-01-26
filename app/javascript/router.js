import { reactive } from 'vue'

export const router = reactive({
  currentRoute: 'dashboard',
  params: {}
})

export function navigateTo(route, params = {}) {
  router.currentRoute = route
  router.params = params
  
  // Push state to URL for better UX
  if (route === 'dashboard') {
    window.history.pushState({}, '', '/')
  } else if (route === 'property-detail' && params.id) {
    window.history.pushState({}, '', `#property/${params.id}`)
  }
}

export function goBack() {
  navigateTo('dashboard', {})
}

export function getCurrentRoute() {
  return router.currentRoute
}

export function getParams() {
  return router.params
}
