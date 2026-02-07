import { createApp } from 'vue'
import axios from 'axios'

// Ensure Font Awesome styles are available even if CDN in layout fails to load
const ensureFontAwesome = () => {
  const existing = document.querySelector('link[data-fa="true"]')
  if (existing) return
  const link = document.createElement('link')
  link.rel = 'stylesheet'
  link.href = 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css'
  link.crossOrigin = 'anonymous'
  link.referrerPolicy = 'no-referrer'
  link.setAttribute('data-fa', 'true')
  document.head.appendChild(link)
}

ensureFontAwesome()

const setAuthHeader = (token) => {
  if (token) {
    axios.defaults.headers.common.Authorization = `Bearer ${token}`
  } else {
    delete axios.defaults.headers.common.Authorization
  }
}

const Auth = {
  emits: ['login'],
  data() {
    return {
      isLogin: true,
      loading: false,
      error: '',
      form: {
        email: '',
        password: '',
        password_confirmation: '',
        first_name: '',
        last_name: '',
        phone: ''
      }
    }
  },
  methods: {
    async handleLogin() {
      this.loading = true
      this.error = ''
      try {
        const response = await axios.post('/api/v1/auth/login', {
          email: this.form.email,
          password: this.form.password
        })
        localStorage.setItem('token', response.data.token)
        localStorage.setItem('user', JSON.stringify(response.data.user))
        setAuthHeader(response.data.token)
        this.$emit('login', response.data.user)
      } catch (err) {
        const apiError = err.response?.data?.error
        if (apiError === 'Invalid email or password') {
          this.error = 'Email ou senha inválidos.'
        } else {
          this.error = apiError || 'Não foi possível entrar. Tente novamente.'
        }
      } finally {
        this.loading = false
      }
    },
    async handleRegister() {
      this.loading = true
      this.error = ''
      try {
        const response = await axios.post('/api/v1/auth/register', {
          user: {
            email: this.form.email,
            password: this.form.password,
            password_confirmation: this.form.password_confirmation,
            first_name: this.form.first_name,
            last_name: this.form.last_name,
            phone: this.form.phone
          }
        })
        localStorage.setItem('token', response.data.token)
        localStorage.setItem('user', JSON.stringify(response.data.user))
        setAuthHeader(response.data.token)
        this.$emit('login', response.data.user)
      } catch (err) {
        if (err.response?.data?.errors) {
          this.error = err.response.data.errors.join(', ')
        } else {
          this.error = 'Não foi possível concluir o cadastro. Tente novamente.'
        }
      } finally {
        this.loading = false
      }
    },
    formatPhone(event) {
      const digits = event.target.value.replace(/\D/g, '').slice(0, 11)
      const parts = []
      if (digits.length > 0) parts.push('(' + digits.slice(0, 2))
      if (digits.length >= 3) {
        parts[0] += ') '
        const middle = digits.length > 6 ? digits.slice(2, 7) : digits.slice(2)
        parts.push(middle)
      }
      if (digits.length > 6) parts.push('-' + digits.slice(7))
      this.form.phone = parts.join('')
    }
  },
  template: `
    <div class="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center p-4">
      <div class="w-full max-w-md">
        <div class="bg-white rounded-2xl shadow-xl p-8 md:p-10">
          <div class="text-center mb-8">
            <h1 class="text-4xl font-bold text-gray-900">TripDay</h1>
            <p class="text-gray-600 mt-2">Gerencie suas propriedades e hóspedes com facilidade</p>
          </div>
          <div class="mb-6 flex gap-2">
            <button
              @click="isLogin = true"
              :class="[
                'flex-1 py-2 px-4 rounded-lg font-semibold transition',
                isLogin ? 'bg-indigo-600 text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              ]"
            >
              Entrar
            </button>
            <button
              @click="isLogin = false"
              :class="[
                'flex-1 py-2 px-4 rounded-lg font-semibold transition',
                !isLogin ? 'bg-indigo-600 text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              ]"
            >
              Cadastro
            </button>
          </div>
          <form @submit.prevent="isLogin ? handleLogin() : handleRegister()" class="space-y-4">
            <div v-if="!isLogin" class="grid grid-cols-2 gap-4">
              <label class="block text-sm font-semibold text-gray-700">
                <span class="mb-1 block">Primeiro Nome</span>
                <input v-model="form.first_name" type="text" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500" />
              </label>
              <label class="block text-sm font-semibold text-gray-700">
                <span class="mb-1 block">Sobrenome</span>
                <input v-model="form.last_name" type="text" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500" />
              </label>
            </div>
            <label class="block text-sm font-semibold text-gray-700">
              <span class="mb-1 block">Endereço de Email</span>
              <input v-model="form.email" type="email" required class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500" />
            </label>
            <label v-if="!isLogin" class="block text-sm font-semibold text-gray-700">
              <span class="mb-1 block">Telefone</span>
              <input v-model="form.phone" type="tel" @input="formatPhone" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500" />
            </label>
            <label class="block text-sm font-semibold text-gray-700">
              <span class="mb-1 block">Senha</span>
              <input v-model="form.password" type="password" required class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500" />
            </label>
            <label v-if="!isLogin" class="block text-sm font-semibold text-gray-700">
              <span class="mb-1 block">Confirmar Senha</span>
              <input v-model="form.password_confirmation" type="password" required class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500" />
            </label>
            <div v-if="error" class="bg-red-50 text-red-600 px-4 py-3 rounded-lg text-sm">{{ error }}</div>
            <button type="submit" :disabled="loading" class="w-full bg-indigo-600 text-white py-2 rounded-lg font-semibold hover:bg-indigo-700 transition disabled:opacity-50">
              {{ loading ? 'Carregando...' : (isLogin ? 'Entrar' : 'Criar Conta') }}
            </button>
          </form>
        </div>
      </div>
    </div>
  `
}

const Navbar = {
  props: ['user'],
  emits: ['logout', 'navigate'],
  data() {
    return {
      openUser: false,
      openCadastros: false,
      mobileOpen: false
    }
  },
  methods: {
    go(view, options = {}) {
      this.openCadastros = false
      this.mobileOpen = false
      this.$emit('navigate', { view, ...options })
    }
  },
  template: `
    <nav class="bg-white/90 backdrop-blur border-b border-gray-200 shadow-sm sticky top-0 z-20">
      <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="h-16 flex items-center justify-between">
          <div class="flex items-center gap-2">
            <div class="h-9 w-9 rounded-lg bg-indigo-600 text-white flex items-center justify-center font-bold">M</div>
            <div class="text-xl font-semibold text-gray-900">TripDay</div>
          </div>
          <button class="md:hidden flex items-center gap-2 text-sm font-semibold text-gray-700" @click="mobileOpen = !mobileOpen">
            Menu
            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" /></svg>
          </button>
          <div class="hidden md:flex items-center gap-6 text-sm font-semibold text-gray-700 relative">
            <div class="relative">
              <button @click="openCadastros = !openCadastros" class="hover:text-indigo-600 transition flex items-center gap-2">
                Cadastros
                <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" /></svg>
              </button>
              <div v-if="openCadastros" class="absolute left-0 mt-2 w-60 bg-white rounded-lg shadow-lg border border-gray-100 py-2">
                <button @click="go('people')" class="w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-50">Pessoas</button>
                <div class="border-t border-gray-100 mt-2">
                  <button @click="go('properties')" class="w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-50">Imóveis</button>
                </div>
              </div>
            </div>
            <button class="hover:text-indigo-600 transition">Locações</button>
          </div>
          <div class="relative">
            <button @click="openUser = !openUser" class="flex items-center gap-2 rounded-full border border-gray-200 bg-white px-3 py-1.5 shadow-sm hover:border-indigo-500 hover:text-indigo-700 transition">
              <span class="text-sm font-semibold text-gray-800">{{ user?.first_name || 'Usuário' }}</span>
              <svg class="h-4 w-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" /></svg>
            </button>
            <div v-if="openUser" class="absolute right-0 mt-2 w-40 bg-white rounded-lg shadow-lg border border-gray-100 py-1">
              <a href="#" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-50">Perfil</a>
              <button @click="$emit('logout')" class="w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-red-50">Sair</button>
            </div>
          </div>
        </div>
        <div v-if="mobileOpen" class="md:hidden pb-4 space-y-2 text-sm font-semibold text-gray-700">
          <div class="bg-white rounded-lg border border-gray-100 shadow-sm">
            <button @click="go('people')" class="w-full text-left px-4 py-3 border-b border-gray-100">Pessoas</button>
            <button @click="go('properties')" class="w-full text-left px-4 py-3 hover:bg-gray-50">Imóveis</button>
          </div>
          <button class="block w-full text-left px-4 py-2 bg-white rounded-lg border border-gray-100 shadow-sm">Locações</button>
        </div>
      </div>
    </nav>
  `
}

const PeopleView = {
  data() {
    return {
      people: [],
      loading: false,
      error: '',
      editingId: null,
      form: this.emptyForm()
    }
  },
  computed: {
    title() {
      return 'Pessoas'
    }
  },
  mounted() {
    this.fetchPeople()
  },
  methods: {
    emptyForm() {
      return {
        name: '',
        cpf: '',
        rg: '',
        phone: '',
        email: '',
        profession: '',
        marital_status: '',
        city: '',
        address: '',
        neighborhood: '',
        zip: '',
        note: '',
        blocked: false,
        comments: '',
        customer: false,
        provider: false,
        agent: false
      }
    },
    roleLabels(person) {
      const roles = []
      if (person.customer) roles.push('Cliente')
      if (person.agent) roles.push('Corretor')
      if (person.provider) roles.push('Prestador')
      return roles.join(', ')
    },
    async fetchPeople() {
      this.loading = true
      this.error = ''
      try {
        const response = await axios.get('/api/v1/people')
        this.people = response.data
      } catch (err) {
        this.error = err.response?.data?.error || 'Não foi possível carregar as pessoas.'
      } finally {
        this.loading = false
      }
    },
    async savePerson() {
      this.loading = true
      this.error = ''
      const payload = { person: { ...this.form } }
      try {
        if (this.editingId) {
          await axios.put(`/api/v1/people/${this.editingId}`, payload)
        } else {
          await axios.post('/api/v1/people', payload)
        }
        await this.fetchPeople()
        this.editingId = null
        this.form = this.emptyForm()
      } catch (err) {
        const errors = err.response?.data?.errors
        this.error = errors ? errors.join(', ') : 'Não foi possível salvar.'
      } finally {
        this.loading = false
      }
    },
    editPerson(person) {
      this.editingId = person.id
      this.form = { ...person, blocked: person.blocked }
    },
    async deletePerson(id) {
      if (!confirm('Deseja remover este registro?')) return
      this.loading = true
      this.error = ''
      try {
        await axios.delete(`/api/v1/people/${id}`)
        await this.fetchPeople()
      } catch (err) {
        this.error = err.response?.data?.errors?.join(', ') || 'Erro ao remover.'
      } finally {
        this.loading = false
      }
    }
  },
  template: `
    <div class="bg-gradient-to-br from-blue-50 to-indigo-100 min-h-screen">
      <div class="max-w-6xl mx-auto px-4 py-10">
        <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-3 mb-6">
          <div>
            <p class="text-sm text-gray-500">Cadastros</p>
            <h1 class="text-3xl font-bold text-gray-900">{{ title }}</h1>
          </div>
          <div class="flex gap-3">
            <button @click="form = emptyForm(); editingId=null" class="px-4 py-2 bg-white text-indigo-700 border border-indigo-200 rounded-lg font-semibold shadow hover:border-indigo-400 transition">Novo</button>
            <button @click="fetchPeople" class="px-4 py-2 bg-indigo-600 text-white rounded-lg font-semibold shadow hover:bg-indigo-700 transition">Atualizar</button>
          </div>
        </div>
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 items-start">
          <div class="lg:col-span-1 bg-white rounded-xl shadow p-5 border border-gray-100">
            <h2 class="text-lg font-semibold text-gray-900 mb-4">{{ editingId ? 'Editar' : 'Cadastrar' }} {{ title }}</h2>
            <form class="space-y-3" @submit.prevent="savePerson">
              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">Perfis *</label>
                <div class="grid grid-cols-1 sm:grid-cols-3 gap-2">
                  <label class="flex items-center gap-2 px-3 py-2 border rounded-lg">
                    <input type="checkbox" v-model="form.customer" class="h-4 w-4 text-indigo-600 border-gray-300 rounded" />
                    <span class="text-sm text-gray-700">Cliente</span>
                  </label>
                  <label class="flex items-center gap-2 px-3 py-2 border rounded-lg">
                    <input type="checkbox" v-model="form.agent" class="h-4 w-4 text-indigo-600 border-gray-300 rounded" />
                    <span class="text-sm text-gray-700">Corretor</span>
                  </label>
                  <label class="flex items-center gap-2 px-3 py-2 border rounded-lg">
                    <input type="checkbox" v-model="form.provider" class="h-4 w-4 text-indigo-600 border-gray-300 rounded" />
                    <span class="text-sm text-gray-700">Prestador</span>
                  </label>
                </div>
              </div>
              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">Nome *</label>
                <input v-model="form.name" required class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500" />
              </div>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-1">CPF *</label>
                  <input v-model="form.cpf" required class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500" />
                </div>
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-1">RG</label>
                  <input v-model="form.rg" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500" />
                </div>
              </div>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-1">Telefone *</label>
                  <input v-model="form.phone" required class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500" />
                </div>
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-1">Email</label>
                  <input v-model="form.email" type="email" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500" />
                </div>
              </div>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-1">Profissão</label>
                  <input v-model="form.profession" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500" />
                </div>
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-1">Estado Civil</label>
                  <input v-model="form.marital_status" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500" />
                </div>
              </div>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-1">Cidade</label>
                  <input v-model="form.city" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500" />
                </div>
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-1">CEP</label>
                  <input v-model="form.zip" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500" />
                </div>
              </div>
              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">Endereço</label>
                <input v-model="form.address" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500" />
              </div>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-1">Bairro</label>
                  <input v-model="form.neighborhood" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500" />
                </div>
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-1">Nota</label>
                  <input v-model="form.note" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500" />
                </div>
              </div>
              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">Observações</label>
                <textarea v-model="form.comments" rows="2" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"></textarea>
              </div>
              <div class="flex items-center gap-2">
                <input id="blocked" type="checkbox" v-model="form.blocked" class="h-4 w-4 text-indigo-600 border-gray-300 rounded" />
                <label for="blocked" class="text-sm text-gray-700">Bloqueado</label>
              </div>
              <button type="submit" :disabled="loading" class="w-full bg-indigo-600 text-white py-2 rounded-lg font-semibold hover:bg-indigo-700 transition disabled:opacity-50">{{ loading ? 'Salvando...' : (editingId ? 'Atualizar' : 'Salvar') }}</button>
              <div v-if="error" class="bg-red-50 text-red-600 px-4 py-3 rounded-lg text-sm">{{ error }}</div>
            </form>
          </div>
          <div class="lg:col-span-2 bg-white rounded-xl shadow p-5 border border-gray-100">
            <div class="flex items-center justify-between mb-4">
              <h2 class="text-lg font-semibold text-gray-900">Lista</h2>
              <span class="text-sm text-gray-500">{{ people.length }} registros</span>
            </div>
            <div v-if="loading" class="text-sm text-gray-500">Carregando...</div>
            <div v-else class="divide-y divide-gray-100">
              <div v-for="person in people" :key="person.id" class="py-3 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-2">
                <div>
                  <div class="flex items-center gap-2">
                    <p class="text-base font-semibold text-gray-900">{{ person.name }}</p>
                    <span v-if="roleLabels(person)" class="px-2 py-0.5 text-xs rounded-full bg-indigo-50 text-indigo-700">{{ roleLabels(person) }}</span>
                    <span v-if="person.blocked" class="px-2 py-0.5 text-xs rounded-full bg-red-50 text-red-700">Bloqueado</span>
                  </div>
                  <p class="text-sm text-gray-600">CPF: {{ person.cpf }} | Tel: {{ person.phone }}</p>
                  <p v-if="person.city" class="text-sm text-gray-500">{{ person.city }}</p>
                </div>
                <div class="flex gap-2">
                  <button @click="editPerson(person)" class="px-3 py-1.5 text-sm bg-white border border-gray-200 rounded-lg hover:border-indigo-400">Editar</button>
                  <button @click="deletePerson(person.id)" class="px-3 py-1.5 text-sm bg-red-50 text-red-700 border border-red-100 rounded-lg hover:bg-red-100">Excluir</button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  `
}

const PropertiesView = {
  data() {
    return {
      properties: [],
      loading: false,
      error: '',
      editingId: null,
      form: this.emptyForm()
    }
  },
  mounted() {
    this.fetchProperties()
  },
  methods: {
    emptyForm() {
      return {
        name: '',
        address: '',
        neighborhood: '',
        zip: '',
        city: '',
        state: '',
        image: '',
        active: true
      }
    },
    async fetchProperties() {
      this.loading = true
      this.error = ''
      try {
        const response = await axios.get('/api/v1/properties')
        this.properties = response.data
      } catch (err) {
        this.error = err.response?.data?.error || 'Não foi possível carregar os imóveis.'
      } finally {
        this.loading = false
      }
    },
    async saveProperty() {
      this.loading = true
      this.error = ''
      const payload = { property: { ...this.form } }
      try {
        if (this.editingId) {
          await axios.put(`/api/v1/properties/${this.editingId}`, payload)
        } else {
          await axios.post('/api/v1/properties', payload)
        }
        await this.fetchProperties()
        this.editingId = null
        this.form = this.emptyForm()
      } catch (err) {
        const errors = err.response?.data?.errors
        this.error = errors ? errors.join(', ') : 'Não foi possível salvar.'
      } finally {
        this.loading = false
      }
    },
    editProperty(property) {
      this.editingId = property.id
      this.form = { ...property, active: property.active }
    },
    async deleteProperty(id) {
      if (!confirm('Deseja remover este imóvel?')) return
      this.loading = true
      this.error = ''
      try {
        await axios.delete(`/api/v1/properties/${id}`)
        await this.fetchProperties()
      } catch (err) {
        this.error = err.response?.data?.errors?.join(', ') || 'Erro ao remover.'
      } finally {
        this.loading = false
      }
    }
  },
  template: `
    <div class="bg-gradient-to-br from-blue-50 to-indigo-100 min-h-screen">
      <div class="max-w-6xl mx-auto px-4 py-10">
        <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-3 mb-6">
          <div>
            <p class="text-sm text-gray-500">Cadastros</p>
            <h1 class="text-3xl font-bold text-gray-900">Imóveis</h1>
          </div>
          <div class="flex gap-3">
            <button @click="form = emptyForm(); editingId=null" class="px-4 py-2 bg-white text-indigo-700 border border-indigo-200 rounded-lg font-semibold shadow hover:border-indigo-400 transition">Novo</button>
            <button @click="fetchProperties" class="px-4 py-2 bg-indigo-600 text-white rounded-lg font-semibold shadow hover:bg-indigo-700 transition">Atualizar</button>
          </div>
        </div>
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 items-start">
          <div class="lg:col-span-1 bg-white rounded-xl shadow p-5 border border-gray-100">
            <h2 class="text-lg font-semibold text-gray-900 mb-4">{{ editingId ? 'Editar' : 'Cadastrar' }} imóvel</h2>
            <form class="space-y-3" @submit.prevent="saveProperty">
              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">Nome *</label>
                <input v-model="form.name" required class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500" />
              </div>
              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">Endereço</label>
                <input v-model="form.address" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500" />
              </div>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-1">Bairro</label>
                  <input v-model="form.neighborhood" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500" />
                </div>
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-1">CEP</label>
                  <input v-model="form.zip" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500" />
                </div>
              </div>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-1">Cidade</label>
                  <input v-model="form.city" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500" />
                </div>
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-1">UF</label>
                  <input v-model="form.state" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500" />
                </div>
              </div>
              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">Imagem (URL)</label>
                <input v-model="form.image" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500" />
              </div>
              <div class="flex items-center gap-2">
                <input id="active" type="checkbox" v-model="form.active" class="h-4 w-4 text-indigo-600 border-gray-300 rounded" />
                <label for="active" class="text-sm text-gray-700">Ativo</label>
              </div>
              <button type="submit" :disabled="loading" class="w-full bg-indigo-600 text-white py-2 rounded-lg font-semibold hover:bg-indigo-700 transition disabled:opacity-50">{{ loading ? 'Salvando...' : (editingId ? 'Atualizar' : 'Salvar') }}</button>
              <div v-if="error" class="bg-red-50 text-red-600 px-4 py-3 rounded-lg text-sm">{{ error }}</div>
            </form>
          </div>
          <div class="lg:col-span-2 bg-white rounded-xl shadow p-5 border border-gray-100">
            <div class="flex items-center justify-between mb-4">
              <h2 class="text-lg font-semibold text-gray-900">Lista</h2>
              <span class="text-sm text-gray-500">{{ properties.length }} registros</span>
            </div>
            <div v-if="loading" class="text-sm text-gray-500">Carregando...</div>
            <div v-else class="grid sm:grid-cols-2 gap-3">
              <div v-for="property in properties" :key="property.id" class="p-4 border border-gray-100 rounded-lg shadow-sm bg-white">
                <div class="flex items-center justify-between mb-1">
                  <p class="text-base font-semibold text-gray-900">{{ property.name }}</p>
                  <span class="px-2 py-0.5 text-xs rounded-full" :class="property.active ? 'bg-green-50 text-green-700' : 'bg-gray-100 text-gray-600'">{{ property.active ? 'Ativo' : 'Inativo' }}</span>
                </div>
                <p class="text-sm text-gray-600">{{ property.address }}</p>
                <p class="text-sm text-gray-500">{{ property.city }} {{ property.state ? ' - ' + property.state : '' }}</p>
                <div class="flex gap-2 mt-3">
                  <button @click="editProperty(property)" class="px-3 py-1.5 text-sm bg-white border border-gray-200 rounded-lg hover:border-indigo-400">Editar</button>
                  <button @click="deleteProperty(property.id)" class="px-3 py-1.5 text-sm bg-red-50 text-red-700 border border-red-100 rounded-lg hover:bg-red-100">Excluir</button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  `
}

const Home = {
  props: ['user'],
  template: `
    <div class="bg-gradient-to-br from-blue-50 to-indigo-100 min-h-screen">
      <div class="max-w-5xl mx-auto px-4 py-16 text-center">
        <h1 class="text-4xl font-bold text-gray-900 mb-4">Bem-vindo(a), {{ user?.first_name || 'Usuário' }}</h1>
        <p class="text-gray-700 text-lg mb-8">Selecione um módulo no menu Cadastros para começar.</p>
        <div class="flex flex-col sm:flex-row gap-3 justify-center">
          <button class="px-6 py-3 bg-indigo-600 text-white rounded-lg font-semibold shadow hover:bg-indigo-700 transition">Cadastros</button>
          <button class="px-6 py-3 bg-white text-indigo-700 border border-indigo-200 rounded-lg font-semibold shadow hover:border-indigo-400 transition">Locações</button>
        </div>
      </div>
    </div>
  `
}

const App = {
  components: { Auth, Navbar, Home, PeopleView, PropertiesView },
  data() {
    return {
      isLoggedIn: false,
      user: null,
      view: 'home'
    }
  },
  computed: {
    currentComponent() {
      if (this.view === 'people') return 'PeopleView'
      if (this.view === 'properties') return 'PropertiesView'
      return 'Home'
    },
    currentProps() {
      return { user: this.user }
    }
  },
  mounted() {
    const token = localStorage.getItem('token')
    if (token) {
      setAuthHeader(token)
      this.isLoggedIn = true
      const savedUser = localStorage.getItem('user')
      this.user = savedUser ? JSON.parse(savedUser) : null
    }
  },
  methods: {
    handleLogin(user) {
      const token = localStorage.getItem('token')
      setAuthHeader(token)
      this.user = user
      this.isLoggedIn = true
    },
    handleLogout() {
      localStorage.removeItem('token')
      localStorage.removeItem('user')
      setAuthHeader(null)
      this.user = null
      this.isLoggedIn = false
      this.view = 'home'
    },
    handleNavigate(payload) {
      this.view = payload.view
    }
  },
  template: `
    <Auth v-if="!isLoggedIn" @login="handleLogin" />
    <div v-else class="min-h-screen bg-gray-50">
      <Navbar :user="user" @logout="handleLogout" @navigate="handleNavigate" />
      <component :is="currentComponent" v-bind="currentProps" />
    </div>
  `
}

createApp(App).mount('#app')
