# 📖 Guia de Manutenção e Uso

## 🎯 Para Desenvolvedores

### Como Usar o Novo `QuickPersonModal`

#### 1. Importar o Componente

```javascript
import QuickPersonModal from './QuickPersonModal.vue'

export default {
  components: {
    QuickPersonModal
  }
}
```

#### 2. No Data, Gerenciar Estado do Modal

```javascript
data() {
  return {
    quickPersonModalOpen: {
      isOpen: false,
      type: null  // 'Customer' | 'Seller' | 'Cleaner'
    }
  }
}
```

#### 3. Criar Handlers

```javascript
methods: {
  openQuickPersonModal(type) {
    this.quickPersonModalOpen = { isOpen: true, type }
  },

  handleQuickPersonSave(person) {
    // person é o objeto retornado do servidor
    // Ex: { id: 1, name: 'João', email: 'joao@email.com', ... }
    
    // Atualizar a variável correta baseado no tipo
    if (this.quickPersonModalOpen.type === 'Customer') {
      this.form.customer_id = person.id
      this.loadCustomers() // Recarregar lista
    }
    // ... outros tipos
    
    this.closeQuickPersonModal()
  },

  closeQuickPersonModal() {
    this.quickPersonModalOpen = { isOpen: false, type: null }
  }
}
```

#### 4. No Template

```vue
<!-- Botão ou select que abre o modal -->
<select v-model.number="form.customer_id" @change="handleCustomerChange">
  <option value="new" class="font-semibold text-indigo-600">+ Novo Hóspede</option>
  <option value="">Selecione um hóspede</option>
  <option v-for="customer in customers" :key="customer.id" :value="customer.id">
    {{ customer.name }}
  </option>
</select>

<!-- O Modal -->
<QuickPersonModal
  :isOpen="quickPersonModalOpen.isOpen"
  :personType="quickPersonModalOpen.type"
  @save="handleQuickPersonSave"
  @close="closeQuickPersonModal"
/>
```

---

### Como Usar o Novo `useInputMasks`

#### 1. Importar

```javascript
import { useInputMasks } from '../composables/useInputMasks.js'

export default {
  setup() {
    const { 
      applyPhoneMask, 
      applyCpfMask, 
      applyRgMask, 
      applyZipMask,
      fetchAddressByCep
    } = useInputMasks()

    return {
      applyPhoneMask,
      applyCpfMask,
      applyRgMask,
      applyZipMask,
      fetchAddressByCep
    }
  }
}
```

#### 2. No Template (Com Form)

```vue
<!-- Telefone -->
<input
  v-model="form.phone"
  @input="event => form.phone = applyPhoneMask(event.target.value)"
  placeholder="(00) 00000-0000"
/>

<!-- CPF -->
<input
  v-model="form.cpf"
  @input="event => form.cpf = applyCpfMask(event.target.value)"
  placeholder="000.000.000-00"
/>

<!-- CEP com busca automática -->
<input
  v-model="form.zip"
  @input="async (event) => {
    form.zip = applyZipMask(event.target.value)
    if (event.target.value.replace(/\D/g, '').length === 8) {
      await fetchAddressByCep(event.target.value.replace(/\D/g, ''), form)
    }
  }"
  placeholder="00000-000"
/>
```

---

## 🔧 Modificar Máscaras de Input

**Caso você precise mudar o formato de uma máscara:**

1. Abra `app/javascript/composables/useInputMasks.js`
2. Encontre a função correspondente (ex: `applyPhoneMask`)
3. Modifique a lógica
4. Salve o arquivo

**Exemplo:** Mudar formato de telefone de `(XX) XXXXX-XXXX` para `XX XXXXX-XXXX`:

```javascript
// ANTES
formattedValue = `(${clean.slice(0, 2)}) ${clean.slice(2, 7)}-${clean.slice(7, 11)}`

// DEPOIS
formattedValue = `${clean.slice(0, 2)} ${clean.slice(2, 7)}-${clean.slice(7, 11)}`
```

✅ **Automático em todos os componentes que usam!**

---

## 🛠️ Adicionar Novo Tipo de Pessoa

### Exemplo: Adicionar tipo "Property Manager"

#### 1. No SelectWithFilter ou select normal:

```vue
<select v-model="form.property_manager_id" @change="handlePropertyManagerChange">
  <option value="new" class="font-semibold text-indigo-600">+ Novo Gerenciador</option>
  <option value="">Selecione um gerenciador</option>
  <option v-for="manager in propertyManagers" :key="manager.id" :value="manager.id">
    {{ manager.name }}
  </option>
</select>
```

#### 2. No Methods:

```javascript
handlePropertyManagerChange(event) {
  if (event.target.value === 'new') {
    this.quickPersonModalOpen = { isOpen: true, type: 'PropertyManager' }
    this.form.property_manager_id = ''
  }
},

handleQuickPersonSave(person) {
  if (this.quickPersonModalOpen.type === 'PropertyManager') {
    this.form.property_manager_id = person.id
    this.loadPropertyManagers()
  }
  this.closeQuickPersonModal()
}
```

#### 3. No QuickPersonModal.vue (sem mudanças!)

Já suporta qualquer tipo! Apenas passa como prop.

---

## 📊 Casos de Uso Comuns

### Use Case 1: Adicionar Campo Novo no Formulário de Pessoa

**Exemplo:** Adicionar "Data de Nascimento"

No `QuickPersonModal.vue`, procure pela section de campos e adicione:

```vue
<div>
  <label class="block text-sm font-medium text-gray-700 mb-1">Data de Nascimento</label>
  <input
    v-model="form.birth_date"
    type="date"
    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
  />
</div>
```

E no data():

```javascript
form: {
  // ... outros campos
  birth_date: '',
}
```

---

### Use Case 2: Modificar Validação

Se quiser mudar requisitos (ex: nome não obrigatório):

No `QuickPersonModal.vue`:

```vue
<!-- ANTES -->
<input v-model="form.name" type="text" required ... />

<!-- DEPOIS -->
<input v-model="form.name" type="text" ... />
```

---

### Use Case 3: Usar em Um Novo Componente

**Exemplo:** Componente "Properties" precisa de Quick Create para Corretores

```javascript
import QuickPersonModal from './QuickPersonModal.vue'

export default {
  components: { QuickPersonModal },
  data() {
    return {
      quickPersonModalOpen: { isOpen: false, type: null },
      sellers: [],
      form: { seller_id: '' }
    }
  },
  methods: {
    openQuickSeller() {
      this.quickPersonModalOpen = { isOpen: true, type: 'Seller' }
    },
    handleQuickSellerSave(seller) {
      this.sellers.push(seller)
      this.form.seller_id = seller.id
      this.closeQuickSeller()
    },
    closeQuickSeller() {
      this.quickPersonModalOpen = { isOpen: false, type: null }
    }
  }
}
```

---

## ⚠️ Troubleshooting

### Problema: Modal não abre

**Solução:**
Verifique se `quickPersonModalOpen.isOpen` está sendo setado como `true`:

```javascript
// ✅ Correto
this.quickPersonModalOpen = { isOpen: true, type: 'Customer' }

// ❌ Errado
this.quickPersonModalOpen.isOpen = true  // Não reativo!
```

---

### Problema: Máscaras não funcionam

**Solução:**
Certifique-se de importar o composable:

```javascript
import { useInputMasks } from '../composables/useInputMasks.js'
```

E que está sendo usado no método:

```javascript
applyPhoneMask(event) {
  event.target.value = this.applyPhoneMask(event.target.value)
}
```

---

### Problema: Pessoa salva mas select não atualiza

**Solução:**
Certifique-se de chamar `loadCustomers()` / `loadSellers()` / etc após salvar:

```javascript
handleQuickPersonSave(person) {
  this.form.customer_id = person.id
  this.loadCustomers()  // ← IMPORTANTE!
  this.closeQuickPersonModal()
}
```

---

## 🧪 Testando a Refatoração

### Manual Testing Checklist

- [ ] Abrir modal de novo hóspede no Bookings
- [ ] Preencher formulário com máscara de telefone
- [ ] Testar autocomplete de endereço com CEP válido
- [ ] Salvar novo hóspede
- [ ] Novo hóspede aparece na lista do select
- [ ] Select de novo hóspede muda para ID correto
- [ ] Repetir para Faxineira e Corretor

### Teste de Máscara

- [ ] Telefone: Digite `11987654321` → deve aparecer `(11) 98765-4321`
- [ ] CPF: Digite `12345678901` → deve aparecer `123.456.789-01`
- [ ] RG: Digite `123456789` → deve aparecer `12.345.678-9`
- [ ] CEP: Digite `01310100` → deve aparecer `01310-100` + buscar endereço

---

## 📚 Documentação Relacionada

- [`REFACTORING_SUMMARY.md`](./REFACTORING_SUMMARY.md) - Sumário das mudanças
- [`REFACTORING_OPPORTUNITIES.md`](./REFACTORING_OPPORTUNITIES.md) - Próximas melhorias
- [`ARCHITECTURE_BEFORE_AFTER.md`](./ARCHITECTURE_BEFORE_AFTER.md) - Comparação visual

---

## 🆘 Precisa de Ajuda?

### Dúvidas sobre o novo componente?
Veja a prop definition em `QuickPersonModal.vue`:

```javascript
props: {
  isOpen: { type: Boolean, required: true },
  personType: { 
    type: String, 
    required: true,
    validator: (value) => ['Customer', 'Seller', 'Cleaner'].includes(value)
  },
  onSave: { type: Function, required: true },
  onClose: { type: Function, required: true }
}
```

### Dúvidas sobre masks?
Veja a implementação em `app/javascript/composables/useInputMasks.js`

### Dúvidas sobre Bookings?
Veja como foi refatorado em `app/javascript/components/Bookings.vue` (linhas dos handlers)

---

**Bom desenvolvimento! 🚀**
