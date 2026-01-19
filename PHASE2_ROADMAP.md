# 🔄 Phase 2 Refactoring Roadmap

## 📌 Status Atual

**Phase 1** ✅ CONCLUÍDA
- `brazilianStates.js` constant criado
- `useApi` composable criado
- `ConfirmationModal` componente criado
- Integrado em Bookings, QuickPersonModal, Profile

**Phase 2** 🔜 PRÓXIMAS MELHORIAS
- Integrar em componentes restantes
- Criar novos composables reutilizáveis

---

## 📋 Phase 2 - High Priority (3-4 horas)

### Task 1: Integrar BRAZILIAN_STATES em Customers.vue, Sellers.vue, Cleaners.vue

**Tempo:** ~30 minutos
**Impacto:** Eliminar duplicação em 3 componentes

**Passos:**
```bash
# Em Customers.vue, Sellers.vue, Cleaners.vue:
1. Adicionar import:
   import { BRAZILIAN_STATES } from '../constants/brazilianStates.js'

2. Substituir em data():
   // ANTES
   const stateOptions = [ { value: 'AC', label: 'Acre' }, ... ]
   
   // DEPOIS (remover completamente, usar global)
   // Usar BRAZILIAN_STATES direto no template

3. Atualizar template de select/options:
   :options="BRAZILIAN_STATES"  // ou v-for
```

**Benefício:** Remove 27 linhas x 3 arquivos = 81 linhas eliminadas

---

### Task 2: Integrar useApi em CrudBase.vue

**Tempo:** ~1.5 horas
**Impacto:** Centraliza CRUD de Customers, Sellers, Cleaners

**Passos:**
```javascript
// Adicionar import
import { useApi } from '../composables/useApi.js'

// Substituir em loadData()
// ANTES
const token = localStorage.getItem('token')
const response = await axios.get(this.apiEndpoint, {
  headers: { Authorization: `Bearer ${token}` }
})

// DEPOIS
const { get } = useApi()
const { data, error } = await get(this.apiEndpoint)
if (!error) this.items = data

// Fazer o mesmo para POST/PUT/DELETE
```

**Benefício:** Remove 50+ linhas, 20+ chamadas axios

---

### Task 3: Integrar ConfirmationModal em CrudBase.vue

**Tempo:** ~30 minutos
**Impacto:** Remove modal antigo, usa componente genérico

**Passos:**
```vue
<!-- ANTES: Modal de confirmação inline (30+ linhas) -->
<div v-if="deleteConfirm" class="fixed inset-0 ...">
  <!-- conteúdo modal -->
</div>

<!-- DEPOIS: Componente reutilizável -->
<ConfirmationModal
  :isOpen="!!deleteConfirm"
  title="Confirmar Exclusão"
  message="Esta ação não pode ser desfeita"
  :loading="deleting"
  @confirm="deleteItem"
  @cancel="deleteConfirm = false"
/>
```

**Benefício:** Remove 30+ linhas, padroniza experiência

---

## 🎯 Phase 2 - Medium Priority (2-3 horas adicionais)

### Task 4: Criar useAsyncState.js Composable

**Arquivo a criar:** `app/javascript/composables/useAsyncState.js`

**Código sugerido:**
```javascript
import { reactive } from 'vue'

export function useAsyncState() {
  const state = reactive({
    loading: false,
    error: null,
    success: false,
    saving: false,
    deleting: false,
    data: null
  })

  const setLoading = (value) => { state.loading = value }
  const setError = (error) => { state.error = error }
  const clearError = () => { state.error = null }
  const setSuccess = (value) => { state.success = value }
  const setSaving = (value) => { state.saving = value }
  const setDeleting = (value) => { state.deleting = value }

  return {
    state,
    setLoading,
    setError,
    clearError,
    setSuccess,
    setSaving,
    setDeleting
  }
}
```

**Onde usar:**
- Bookings.vue (loading, saving, deleting)
- Customers.vue (loading, saving, deleting)
- Sellers.vue (loading, saving, deleting)
- Cleaners.vue (loading, saving, deleting)

**Benefício:** Remove 15 linhas x múltiplos componentes, state management padronizado

---

### Task 5: Criar useFormValidation.js Composable

**Arquivo a criar:** `app/javascript/composables/useFormValidation.js`

**Código sugerido:**
```javascript
import { reactive } from 'vue'

export function useFormValidation(schema = {}) {
  const errors = reactive({})

  const validate = (form) => {
    clearErrors()
    
    Object.keys(schema).forEach(field => {
      const rule = schema[field]
      const value = form[field]

      if (rule.required && (!value || value.toString().trim() === '')) {
        errors[field] = `${rule.label} é obrigatório`
        return
      }

      if (rule.pattern && !rule.pattern.test(value)) {
        errors[field] = rule.message || 'Formato inválido'
        return
      }

      if (rule.minLength && value.length < rule.minLength) {
        errors[field] = `Mínimo ${rule.minLength} caracteres`
        return
      }
    })

    return Object.keys(errors).length === 0
  }

  const clearErrors = () => {
    Object.keys(errors).forEach(key => delete errors[key])
  }

  const hasErrors = () => Object.keys(errors).length > 0

  return { errors, validate, clearErrors, hasErrors }
}
```

**Onde usar:**
- Todos os formulários (QuickPersonModal, Profile, Customers, etc)

**Benefício:** Remove 20+ linhas x componente, validação consistente

---

## 🎓 Phase 2 - Implementation Guide

### Ordem Recomendada:
1. **Task 1** (BRAZILIAN_STATES) - Mais rápido, máximo impacto
2. **Task 2** (useApi em CrudBase) - Maior refatoração, máximo benefício
3. **Task 3** (ConfirmationModal em CrudBase) - Quebra compatível
4. **Task 4** (useAsyncState) - Novo padrão, aplicar globalmente
5. **Task 5** (useFormValidation) - Novo padrão, aplicar globalmente

### Cronograma Sugerido:
- **Dia 1 (1.5 horas):** Tasks 1 + 2
- **Dia 2 (1 hora):** Task 3
- **Dia 3 (2 horas):** Tasks 4 + 5

### Teste Recomendado:
Após cada task, rodar:
```bash
npm run lint  # ou seu linter
```

---

## 🔄 Como Usar Composables na Phase 2

### Exemplo: Refatorar Customers.vue

**ANTES:**
```javascript
data() {
  return {
    customers: [],
    loading: false,
    saving: false,
    errors: {},
    form: { name: '', email: '', ... },
    stateOptions: [ { value: 'AC', ... } ]
  }
},

methods: {
  async loadCustomers() {
    this.loading = true
    const token = localStorage.getItem('token')
    try {
      const response = await axios.get('/api/v1/people?type=Customer', {
        headers: { Authorization: `Bearer ${token}` }
      })
      this.customers = response.data
    } finally {
      this.loading = false
    }
  },

  async saveCustomer() {
    this.saving = true
    const token = localStorage.getItem('token')
    try {
      await axios.post('/api/v1/people', { person: this.form }, {
        headers: { Authorization: `Bearer ${token}` }
      })
      this.loadCustomers()
    } finally {
      this.saving = false
    }
  }
}
```

**DEPOIS:**
```javascript
import { useApi } from '../composables/useApi.js'
import { useAsyncState } from '../composables/useAsyncState.js'
import { useFormValidation } from '../composables/useFormValidation.js'
import { BRAZILIAN_STATES } from '../constants/brazilianStates.js'

setup() {
  const { getPeople, post } = useApi()
  const { state, setLoading, setSaving } = useAsyncState()
  const { errors, validate, clearErrors } = useFormValidation()

  const form = reactive({ name: '', email: '', ... })

  const loadCustomers = async () => {
    setLoading(true)
    const { data } = await getPeople('Customer')
    customers.value = data
    setLoading(false)
  }

  const saveCustomer = async () => {
    if (!validate(form)) return
    
    setSaving(true)
    const { data, error } = await post('/api/v1/people', { person: form })
    if (!error) {
      clearErrors()
      loadCustomers()
    }
    setSaving(false)
  }

  return {
    state,
    form,
    errors,
    stateOptions: BRAZILIAN_STATES,
    loadCustomers,
    saveCustomer
  }
}
```

---

## 📊 Phase 2 - Impacto Esperado

| Refatoração | Linhas Removidas | Componentes | Impacto |
|------------|------------------|------------|---------|
| BRAZILIAN_STATES | 81 | 3 | Consolidação |
| useApi em CrudBase | 100+ | 4 | Centralização |
| ConfirmationModal | 30 | 2 | Unificação |
| useAsyncState | 60+ | 6+ | Padronização |
| useFormValidation | 100+ | 6+ | Consistência |
| **TOTAL** | **~370+ linhas** | **Toda a app** | **Arquitetura escalável** |

---

## ✅ Próximas Actions

- [ ] Revisar Phase 1 se ainda não fez
- [ ] Começar Phase 2 quando estiver pronto
- [ ] Testar cada mudança conforme avança
- [ ] Atualizar documentação após cada task

---

**Roadmap completo da refatoração! Boa sorte! 🚀**
