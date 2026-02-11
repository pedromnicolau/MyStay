# Nova Funcionalidade: Templates de Contrato Personalizados ✨

## O que foi implementado

O sistema MyStay agora suporta templates de contrato personalizados! Você pode criar seus próprios modelos de contrato no Microsoft Word e o sistema automaticamente substitui as variáveis pelos dados reais da hospedagem.

## Como funciona

### 1. **Template com Variáveis**
   - Crie um arquivo Word (.docx) com o layout do seu contrato
   - Use variáveis no formato `[NOME_VARIAVEL]` onde quiser dados dinâmicos
   - Exemplo: `[CLIENTE_NOME]`, `[CHECK_IN_DATA]`, `[VALOR_TOTAL]`

### 2. **Anexe ao Imóvel**
   - Vá em Imóveis > Editar imóvel
   - Seção "Contrato do Imóvel"
   - Faça upload do arquivo .docx

### 3. **Exporte Contratos**
   - Ao exportar um contrato de hospedagem
   - O sistema usa o template do imóvel
   - Todas as variáveis são substituídas automaticamente

## Arquivos criados/modificados

### Novos Arquivos

1. **`app/services/contract_template_processor.rb`**
   - Processador principal que substitui as variáveis
   - Valida dados obrigatórios
   - Retorna erros detalhados se faltar algum dado

2. **`docs/CONTRACT_VARIABLES.md`**
   - Lista completa de todas as variáveis disponíveis
   - Exemplos de uso

3. **`docs/CONTRACT_TEMPLATES.md`**
   - Guia completo de como usar a funcionalidade
   - Passo a passo detalhado

4. **`docs/QUICK_START_CONTRACTS.md`**
   - Guia rápido de início
   - Exemplo visual de template

### Arquivos Modificados

1. **`Gemfile`**
   - Adicionado `gem "rubyzip"` para processar arquivos .docx

2. **`app/controllers/api/v1/movements_controller.rb`**
   - Método `contract` atualizado para usar templates personalizados
   - Fallback para gerador padrão se não houver template
   - Tratamento de erros com mensagens detalhadas

3. **`app/javascript/components/Bookings.vue`**
   - Método `exportContract` melhorado
   - Tratamento de erros do backend
   - Mostra mensagens descritivas ao usuário

4. **`app/javascript/components/Properties.vue`**
   - Adicionado aviso informativo sobre como usar variáveis
   - Link para documentação

## Variáveis Disponíveis (principais)

### Cliente
- `[CLIENTE_NOME]`, `[CLIENTE_CPF]`, `[CLIENTE_RG]`
- `[CLIENTE_EMAIL]`, `[CLIENTE_TELEFONE]`
- `[CLIENTE_ENDERECO]`, `[CLIENTE_PROFISSAO]`

### Hospedagem
- `[CHECK_IN_DATA]`, `[CHECK_OUT_DATA]`
- `[CHECK_IN_HORA]`, `[CHECK_OUT_HORA]`
- `[NUMERO_NOITES]`, `[NUMERO_HOSPEDES]`
- `[VALOR_TOTAL]`, `[VALOR_SINAL]`, `[VALOR_SALDO]`
- `[DATA_VENCIMENTO_SALDO]`

### Imóvel
- `[IMOVEL_NOME]`, `[IMOVEL_ENDERECO]`
- `[IMOVEL_CIDADE]`, `[IMOVEL_ESTADO]`
- `[IMOVEL_QUARTOS]`, `[IMOVEL_BANHEIROS]`
- `[IMOVEL_CAPACIDADE]`

### Outras
- `[DATA_HOJE]`, `[CIDADE_ESTADO]`
- `[VENDEDOR_NOME]`, `[VENDEDOR_TELEFONE]`

📖 **Lista completa:** [docs/CONTRACT_VARIABLES.md](./docs/CONTRACT_VARIABLES.md)

## Validação de Dados

O sistema valida automaticamente se todos os dados obrigatórios estão preenchidos:

**Obrigatórios:**
- ✅ Nome do cliente
- ✅ CPF do cliente
- ✅ Data de check-in
- ✅ Data de check-out
- ✅ Valor total
- ✅ Nome do imóvel
- ✅ Endereço do imóvel

Se faltar algum dado, o sistema mostra uma mensagem clara informando o que precisa ser preenchido.

## Exemplo de Uso

```
CONTRATO DE LOCAÇÃO POR TEMPORADA

LOCATÁRIO: [CLIENTE_NOME]
CPF: [CLIENTE_CPF]
Telefone: [CLIENTE_TELEFONE]

IMÓVEL: [IMOVEL_NOME]
Endereço: [IMOVEL_ENDERECO]

PERÍODO:
Check-in: [CHECK_IN_DATA] às [CHECK_IN_HORA]
Check-out: [CHECK_OUT_DATA] às [CHECK_OUT_HORA]
Total: [NUMERO_NOITES]

VALOR: [VALOR_TOTAL]
Sinal: [VALOR_SINAL]
Saldo: [VALOR_SALDO] (vencimento: [DATA_VENCIMENTO_SALDO])

[CIDADE_ESTADO], [DATA_HOJE]
```

## Tecnologia

- **Ruby on Rails 8** - Backend
- **rubyzip** - Manipulação de arquivos .docx
- **Nokogiri** - Processamento XML
- **Active Storage** - Armazenamento de templates
- **Vue.js 3** - Frontend

## Fluxo Técnico

1. Template .docx é armazenado no Active Storage
2. Ao exportar, o sistema baixa o template
3. Arquivo .docx é descompactado (é um ZIP)
4. O XML interno é processado com Nokogiri
5. Todas as variáveis `[VARIAVEL]` são substituídas
6. O arquivo é recompactado
7. Download é feito automaticamente

## Tratamento de Erros

### Frontend
- Detecta resposta de erro do backend
- Mostra mensagens claras ao usuário
- Lista os campos que precisam ser preenchidos

### Backend
- Classe customizada `MissingDataError`
- Valida dados antes de processar
- Retorna JSON com lista de campos faltantes
- HTTP 422 para dados faltando

## Compatibilidade

- ✅ Microsoft Word (.docx)
- ✅ LibreOffice Writer (.docx)
- ✅ Google Docs (exportado como .docx)
- ❌ Word 97-2003 (.doc) - não suportado

## Fallback

Se um imóvel não tiver template anexado, o sistema usa automaticamente o gerador de contrato padrão (`ContractGenerator`), mantendo compatibilidade total com o sistema anterior.

## Testes

Para testar:

```bash
# Verificar se a classe carrega
bin/rails runner "puts ContractTemplateProcessor.new(Stay.first).class.name"

# Verificar se tem hospedagens para testar
bin/rails runner "
stay = Stay.includes(:customer, :property, :seller).first
puts 'Stay ID: ' + stay.id.to_s
puts 'Customer: ' + (stay.customer&.name || 'N/A')
puts 'Property: ' + (stay.property&.name || 'N/A')
puts 'Has contract: ' + (stay.property&.contract&.attached? ? 'Yes' : 'No')
"
```

## Documentação

- 📘 [Guia Completo](./docs/CONTRACT_TEMPLATES.md)
- 📋 [Lista de Variáveis](./docs/CONTRACT_VARIABLES.md)
- 🚀 [Início Rápido](./docs/QUICK_START_CONTRACTS.md)

## Próximos Passos (Sugestões)

1. Criar templates de exemplo prontos para uso
2. Adicionar preview do contrato antes de exportar
3. Suportar múltiplos idiomas nas variáveis
4. Permitir templates globais (não apenas por imóvel)
5. Adicionar editor visual de templates

## Autor

Implementação solicitada por: @pedromnicolau
Data: 11 de fevereiro de 2026

---

**Enjoy! 🎉**
