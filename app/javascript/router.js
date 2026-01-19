import { reactive } from 'vue'

export const router = reactive({
  currentRoute: 'dashboard',
  params: {}
})

export function navigateTo(route, params = {}) {
  router.currentRoute = route
  router.params = params
}
