# 📚 Documentação do MyStay

## 🆕 Nova Funcionalidade: Templates de Contrato

O MyStay agora suporta templates de contrato personalizados com substituição automática de variáveis!

### 📖 Documentação Disponível

#### 🚀 Para Começar
- **[Guia Rápido (QUICK_START_CONTRACTS.md)](./QUICK_START_CONTRACTS.md)**  
  Aprenda em 5 minutos como usar a funcionalidade

#### 📋 Referências
- **[Lista de Variáveis (CONTRACT_VARIABLES.md)](./CONTRACT_VARIABLES.md)**  
  Todas as 50+ variáveis disponíveis para usar nos templates

- **[Exemplo de Template (TEMPLATE_EXAMPLE.md)](./TEMPLATE_EXAMPLE.md)**  
  Template completo pronto para copiar e usar

#### 📘 Guias Completos
- **[Guia de Templates (CONTRACT_TEMPLATES.md)](./CONTRACT_TEMPLATES.md)**  
  Documentação completa com todos os detalhes

- **[Resumo da Implementação (IMPLEMENTATION_SUMMARY.md)](./IMPLEMENTATION_SUMMARY.md)**  
  Checklist completo do que foi implementado

- **[Documentação Técnica (FEATURE_CONTRACT_TEMPLATES.md)](./FEATURE_CONTRACT_TEMPLATES.md)**  
  Detalhes técnicos para desenvolvedores

### 🎯 Fluxo de Uso

```
1. Ler Guia Rápido
        ↓
2. Ver Lista de Variáveis
        ↓
3. Copiar Exemplo de Template
        ↓
4. Criar seu template no Word
        ↓
5. Anexar no imóvel
        ↓
6. Exportar contratos!
```

### 📂 Estrutura de Arquivos

```
docs/
├── README.md (este arquivo)
├── QUICK_START_CONTRACTS.md      ← Comece aqui!
├── CONTRACT_VARIABLES.md          ← Consulte variáveis aqui
├── TEMPLATE_EXAMPLE.md            ← Copie o exemplo
├── CONTRACT_TEMPLATES.md          ← Guia completo
├── IMPLEMENTATION_SUMMARY.md      ← Para saber o que foi feito
└── FEATURE_CONTRACT_TEMPLATES.md  ← Para desenvolvedores
```

### 🔍 Encontre Rapidamente

| Preciso de... | Vá para... |
|---------------|------------|
| Aprender a usar rapidamente | [QUICK_START_CONTRACTS.md](./QUICK_START_CONTRACTS.md) |
| Ver que variáveis existem | [CONTRACT_VARIABLES.md](./CONTRACT_VARIABLES.md) |
| Um exemplo de contrato | [TEMPLATE_EXAMPLE.md](./TEMPLATE_EXAMPLE.md) |
| Ajuda com problemas | [CONTRACT_TEMPLATES.md](./CONTRACT_TEMPLATES.md#solução-de-problemas) |
| Detalhes técnicos | [FEATURE_CONTRACT_TEMPLATES.md](./FEATURE_CONTRACT_TEMPLATES.md) |

### 💡 Dicas Rápidas

#### ✅ Variáveis Mais Usadas
```
[CLIENTE_NOME]      - Nome do cliente
[CLIENTE_CPF]       - CPF do cliente
[CHECK_IN_DATA]     - Data de entrada
[CHECK_OUT_DATA]    - Data de saída
[VALOR_TOTAL]       - Valor da hospedagem
[IMOVEL_NOME]       - Nome do imóvel
[IMOVEL_ENDERECO]   - Endereço completo
```

#### ⚠️ Dados Obrigatórios
Para gerar contrato, você DEVE ter:
- Nome e CPF do cliente
- Datas de check-in e check-out
- Valor total
- Nome e endereço do imóvel

#### 🎨 Formatação
- Use negrito, itálico, cores no Word
- Crie tabelas, listas, numerações
- Tudo será preservado no contrato final!

### 🧪 Testar a Funcionalidade

Execute o script de teste:
```bash
bin/rails runner script/test_contract_template.rb
```

### 🆘 Precisa de Ajuda?

1. **Problema com variáveis?**  
   → Consulte [CONTRACT_VARIABLES.md](./CONTRACT_VARIABLES.md)

2. **Erro ao exportar?**  
   → Veja seção "Solução de Problemas" em [CONTRACT_TEMPLATES.md](./CONTRACT_TEMPLATES.md)

3. **Quer entender como funciona?**  
   → Leia [FEATURE_CONTRACT_TEMPLATES.md](./FEATURE_CONTRACT_TEMPLATES.md)

4. **Dúvida técnica?**  
   → Veja o código em `app/services/contract_template_processor.rb`

### 📝 Exemplos Rápidos

#### Exemplo Mínimo
```
CONTRATO DE LOCAÇÃO

Cliente: [CLIENTE_NOME]
CPF: [CLIENTE_CPF]

Período: [CHECK_IN_DATA] a [CHECK_OUT_DATA]
Valor: [VALOR_TOTAL]
```

#### Exemplo Completo
Veja [TEMPLATE_EXAMPLE.md](./TEMPLATE_EXAMPLE.md)

### 🌟 Recursos Especiais

- ✅ **Validação Automática**: Sistema avisa se faltar dados
- ✅ **Formatação Preservada**: Cores, negritos, tabelas mantidos
- ✅ **Múltiplas Variáveis**: 50+ variáveis disponíveis
- ✅ **Fallback Inteligente**: Usa gerador padrão se não houver template
- ✅ **Mensagens Claras**: Erros descritivos e úteis

### 🚀 Começe Agora!

1. **Leia**: [QUICK_START_CONTRACTS.md](./QUICK_START_CONTRACTS.md)
2. **Copie**: [TEMPLATE_EXAMPLE.md](./TEMPLATE_EXAMPLE.md)
3. **Use**: Anexe no imóvel e exporte contratos!

---

**Versão**: 1.0  
**Data**: 11 de fevereiro de 2026  
**Status**: ✅ Produção

Boa sorte com seus contratos! 🎉
