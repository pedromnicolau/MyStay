import { createApp } from 'vue'
import axios from 'axios'
import '@fortawesome/fontawesome-free/css/all.min.css'
import App from '../App.vue'

axios.interceptors.request.use((config) => {
	const userToken = localStorage.getItem('userToken')
	const tenantToken = localStorage.getItem('tenantToken')

	if (userToken) {
		config.headers.Authorization = `Bearer ${userToken}`
	}

	if (tenantToken) {
		config.headers['Tenant-Authorization'] = `Bearer ${tenantToken}`
	}

	return config
})

createApp(App).mount('#app')
