# 🎯 Oportunidades Futuras de Refatoração

## 📌 Padrões Duplicados Identificados (Próximas Melhorias)

### 1. Customers, Sellers, Cleaners - Formulários Duplicados

**Arquivos afetados:**
- `app/javascript/components/Customers.vue`
- `app/javascript/components/Sellers.vue`
- `app/javascript/components/Cleaners.vue`

**Problema:** Cada componente tem seu próprio formulário com campos idênticos (Nome, Email, Telefone, CPF, RG, etc.)

**Solução Proposta:**
Criar um componente `PersonFormFields.vue` que renderiza o formulário genérico com slots para customização:

```vue
<PersonFormFields 
  :form="form" 
  :errors="errors"
  @update:form="form = $event"
>
  <template #extra>
    <!-- Campos específicos do componente -->
  </template>
</PersonFormFields>
```

---

### 2. Modal de Confirmação de Exclusão Duplicado

**Arquivos afetados:**
- `Bookings.vue` - Modal de confirmação de exclusão de locação
- `CrudBase.vue` - Modal de confirmação com listing de stays relacionadas

**Problema:** Padrão de modal de confirmação repetido em múltiplos componentes

**Solução Proposta:**
Criar componente `ConfirmationModal.vue`:

```vue
<ConfirmationModal
  :isOpen="deleteConfirmOpen"
  title="Confirmar Exclusão"
  message="Tem certeza que deseja excluir?"
  :loading="deleting"
  @confirm="deleteItem"
  @cancel="closeConfirm"
/>
```

---

### 3. Tabela de Listagem (CrudBase)

**Arquivo:** `app/javascript/components/CrudBase.vue`

**Problema:** Componente muito genérico, pode ser dividido em responsabilidades menores

**Solução Proposta:**
- Extrair `DataTable.vue` - Apenas tabela
- Extrair `DataTableActions.vue` - Botões de ação (editar, deletar)
- Extrair `CrudHeader.vue` - Cabeçalho com título e botão novo
- Manter `CrudBase.vue` como orquestrador

---

### 4. Estados de Loading e Error Duplicados

**Problema:** Padrão de `loading`, `error`, `saving` se repete em vários componentes

**Solução Proposta:**
Criar composable `useAsyncState.js`:

```javascript
export function useAsyncState() {
  const state = reactive({
    loading: false,
    error: null,
    success: false,
    saving: false
  })

  const setLoading = (value) => { state.loading = value }
  const setError = (error) => { state.error = error }
  const clearError = () => { state.error = null }
  const setSuccess = (value) => { state.success = value }

  return { state, setLoading, setError, clearError, setSuccess }
}
```

---

### 5. Chamadas de API Duplicadas

**Padrão que se repete:**
```javascript
const response = await axios.get('/api/v1/...', {
  headers: { Authorization: `Bearer ${token}` }
})
```

**Solução Proposta:**
Criar composable `useApi.js`:

```javascript
export function useApi() {
  const getToken = () => localStorage.getItem('token')
  
  const apiCall = (method, endpoint, data = null) => {
    const headers = { Authorization: `Bearer ${getToken()}` }
    
    if (method === 'GET') return axios.get(endpoint, { headers })
    if (method === 'POST') return axios.post(endpoint, data, { headers })
    if (method === 'PUT') return axios.put(endpoint, data, { headers })
    if (method === 'DELETE') return axios.delete(endpoint, { headers })
  }

  return { apiCall, getToken }
}
```

---

### 6. States Options Duplicado

**Problema:** `stateOptions` (lista de estados brasileiros) está em `Bookings.vue` e `QuickPersonModal.vue`

**Solução Proposta:**
Criar constants file:

```javascript
// constants/brazilianStates.js
export const BRAZILIAN_STATES = [
  { value: 'AC', label: 'Acre' },
  { value: 'AL', label: 'Alagoas' },
  // ...
]
```

---

### 7. Form Validation Padrão

**Problema:** Cada formulário tem sua própria lógica de validação

**Solução Proposta:**
Criar composable `useFormValidation.js`:

```javascript
export function useFormValidation(schema) {
  const errors = reactive({})
  
  const validate = (form) => {
    // Validar contra schema
    return errors
  }

  const clearErrors = () => { Object.keys(errors).forEach(key => delete errors[key]) }

  return { errors, validate, clearErrors }
}
```

---

## 📊 Estimativa de Impacto

| Refatoração | Linhas Duplicadas | Tempo Est. | Prioridade |
|------------|-------------------|-----------|-----------|
| PersonFormFields | ~200 | 1-2h | 🔴 Alta |
| ConfirmationModal | ~100 | 30min | 🔴 Alta |
| useAsyncState | ~150 | 1h | 🟡 Média |
| useApi | ~200 | 2-3h | 🔴 Alta |
| brazilianStates | ~30 | 15min | 🟢 Baixa |
| useFormValidation | ~100 | 1-2h | 🟡 Média |

---

## 🚀 Roadmap Sugerido

### Phase 1 (Próximo Sprint) - Máximo Impacto
1. Extrair `brazilianStates` constants
2. Criar `useApi` composable
3. Criar `ConfirmationModal` componente

### Phase 2 (Sprint Seguinte) - Consolidação
4. Criar `PersonFormFields` componente
5. Refatorar Customers, Sellers, Cleaners para usar novo componente

### Phase 3 (Futuro) - Polimento
6. Implementar `useAsyncState` composable
7. Implementar `useFormValidation` composable
8. Refatorar CrudBase em componentes menores

---

## 💡 Benefícios Esperados

✅ **Manutenibilidade:** -40% de código duplicado  
✅ **Performance:** Bundle menor (~5-8kb redução)  
✅ **Consistência:** UI/UX uniforme em toda a aplicação  
✅ **Velocidade de Desenvolvimento:** Novos formulários 3x mais rápido  
✅ **Testabilidade:** Lógica desacoplada, fácil de testar  

---

## 📝 Como Começar

1. Escolha uma refatoração da Phase 1
2. Crie o composable/componente novo
3. Refatore um componente para usá-lo
4. Teste completamente
5. Aplique para os outros componentes

---

**Próxima refatoração? Chame-me quando desejar! 🎉**
