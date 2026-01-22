# AttachmentManager Component

Componente reutilizável para gerenciamento de anexos (arquivos, imagens, vídeos) em qualquer formulário da aplicação.

## Funcionalidades

- ✅ Upload de múltiplos arquivos
- ✅ Preview de imagens, vídeos e outros tipos de arquivo
- ✅ Drag & Drop para adicionar arquivos
- ✅ Remoção de anexos existentes e novos
- ✅ Reordenação por drag & drop (opcional)
- ✅ Integração com lightbox (opcional)
- ✅ Gerenciamento automático de memória (cleanup de URLs)
- ✅ Suporte para anexos existentes (do backend) e novos (local)

## Uso Básico

```vue
<template>
  <div>
    <AttachmentManager
      v-model="form.attachments"
      v-model:remove-attachment-ids="form.remove_attachment_ids"
    />
  </div>
</template>

<script>
import AttachmentManager from './AttachmentManager.vue'

export default {
  components: { AttachmentManager },
  data() {
    return {
      form: {
        attachments: [],
        remove_attachment_ids: []
      }
    }
  }
}
</script>
```

## Props

### `modelValue` (Array)
- **Tipo**: `Array`
- **Default**: `[]`
- **Descrição**: Array contendo anexos existentes (objetos com `id`, `url`, etc.) e novos arquivos (File/Blob)

### `removeAttachmentIds` (Array)
- **Tipo**: `Array`
- **Default**: `[]`
- **Descrição**: Array de IDs dos anexos existentes marcados para remoção

### `acceptedTypes` (String)
- **Tipo**: `String`
- **Default**: `'*'`
- **Descrição**: Tipos de arquivo aceitos (ex: `'image/*,video/*'`, `'.pdf,.doc'`)

### `enableReorder` (Boolean)
- **Tipo**: `Boolean`
- **Default**: `false`
- **Descrição**: Habilita reordenação por drag & drop dos anexos

### `enableLightbox` (Boolean)
- **Tipo**: `Boolean`
- **Default**: `false`
- **Descrição**: Habilita clique nos anexos para abrir lightbox (emite evento)

### `addButtonText` (String)
- **Tipo**: `String`
- **Default**: `'Clique ou arraste arquivos para adicionar anexos'`
- **Descrição**: Texto do botão de adicionar anexos

## Eventos

### `@update:modelValue`
Emitido quando a lista de anexos é modificada (adição ou remoção)

### `@update:removeAttachmentIds`
Emitido quando um anexo existente é marcado para remoção

### `@open-lightbox`
Emitido quando um anexo é clicado (somente se `enableLightbox` = true)
- **Payload**: `index` (número) - índice do anexo clicado

## Exemplos de Uso

### 1. Upload Simples (sem reordenação)

```vue
<AttachmentManager
  v-model="form.attachments"
  v-model:remove-attachment-ids="form.remove_attachment_ids"
  accepted-types="image/*,video/*"
  add-button-text="Adicionar fotos ou vídeos"
/>
```

### 2. Com Reordenação (Properties/Imóveis)

```vue
<AttachmentManager
  v-model="form.attachments"
  v-model:remove-attachment-ids="form.remove_attachment_ids"
  :enable-reorder="true"
  :enable-lightbox="true"
  accepted-types="image/*,video/*"
  @open-lightbox="openLightbox"
/>
```

### 3. Documentos (PDFs, Word, etc)

```vue
<AttachmentManager
  v-model="form.documents"
  v-model:remove-attachment-ids="form.remove_document_ids"
  accepted-types=".pdf,.doc,.docx,.xls,.xlsx"
  add-button-text="Adicionar documentos"
/>
```

### 4. Todos os tipos de arquivo

```vue
<AttachmentManager
  v-model="form.attachments"
  v-model:remove-attachment-ids="form.remove_attachment_ids"
  accepted-types="*"
/>
```

## Estrutura de Dados

### Anexo Existente (do backend)
```javascript
{
  id: 123,
  filename: 'imagem.jpg',
  content_type: 'image/jpeg',
  url: 'https://exemplo.com/storage/imagem.jpg',
  byte_size: 204800
}
```

### Anexo Novo (local)
```javascript
File {
  name: 'nova-imagem.jpg',
  type: 'image/jpeg',
  size: 102400,
  lastModified: 1640000000000,
  // + propriedades do File API
}
```

## Integração com Backend

O componente prepara os dados para envio via FormData. No backend Rails:

```ruby
# Controller
def service_params
  params.require(:service).permit(
    # ... outros campos
    attachments: [],
    remove_attachment_ids: []
  )
end

def process_attachments(service)
  # Anexar novos arquivos
  if params.dig(:service, :attachments).present?
    service.attachments.attach(params[:service][:attachments])
  end
  
  # Remover anexos marcados
  if params.dig(:service, :remove_attachment_ids).present?
    params[:service][:remove_attachment_ids].each do |id|
      attachment = service.attachments.find_by(id: id)
      attachment&.purge_later
    end
  end
end
```

## Notas Técnicas

1. **Gerenciamento de Memória**: O componente cria URLs temporárias para preview de novos arquivos usando `URL.createObjectURL()`. É importante limpar essas URLs quando não forem mais necessárias.

2. **Reatividade**: O componente usa `v-model` com modificador `.sync` para manter sincronização bidirecional com o componente pai.

3. **Performance**: Anexos existentes são filtrados e renderizados separadamente dos novos para melhor performance e visual.

4. **Acessibilidade**: Botões de remoção têm símbolos × claros e hover states para feedback visual.

5. **Drag & Drop**: 
   - Drag & drop para adicionar: sempre habilitado
   - Drag & drop para reordenar: somente se `enableReorder` = true

## Migração de Código Existente

Para migrar código que gerencia anexos manualmente:

**Antes:**
```vue
<template>
  <div v-for="file in files">
    <img :src="file.url" />
    <button @click="removeFile(file)">×</button>
  </div>
  <input type="file" @change="addFiles" />
</template>

<script>
export default {
  methods: {
    addFiles(e) { /* ... */ },
    removeFile(file) { /* ... */ },
    // + vários outros métodos
  }
}
</script>
```

**Depois:**
```vue
<template>
  <AttachmentManager
    v-model="form.attachments"
    v-model:remove-attachment-ids="form.remove_attachment_ids"
  />
</template>

<script>
import AttachmentManager from './AttachmentManager.vue'

export default {
  components: { AttachmentManager }
}
</script>
```

## Implementações Atuais

✅ **Bookings.vue** - Anexos de locações/serviços (sem reordenação)  
🔄 **Properties.vue** - Pode ser migrado para usar o componente com reordenação

## Próximos Passos

Para completar a refatoração no Properties.vue, seria necessário:
1. Importar AttachmentManager
2. Substituir a seção de anexos pelo componente
3. Manter a integração com lightbox existente
4. Manter a lógica de sincronização do anexo principal (primeiro = principal)
