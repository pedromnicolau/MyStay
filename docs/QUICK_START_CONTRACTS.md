# Guia Rápido: Configurando Templates de Contrato

## Passo 1: Prepare seu Template no Word

1. Abra o Microsoft Word ou LibreOffice Writer
2. Crie seu contrato com o layout desejado
3. Use as variáveis onde quer dados dinâmicos

### Exemplo de Template:

```
═══════════════════════════════════════════════════════
            CONTRATO DE LOCAÇÃO POR TEMPORADA
═══════════════════════════════════════════════════════

1. IDENTIFICAÇÃO DAS PARTES

LOCADOR: [Seus dados fixos aqui]
Endereço: [Seu endereço fixo]
CPF/CNPJ: [Seu documento fixo]

LOCATÁRIO: [CLIENTE_NOME]
CPF: [CLIENTE_CPF]
RG: [CLIENTE_RG]
Endereço: [CLIENTE_ENDERECO]
Telefone: [CLIENTE_TELEFONE]
E-mail: [CLIENTE_EMAIL]

2. OBJETO DO CONTRATO

O presente contrato tem por objeto a locação temporária do imóvel 
denominado [IMOVEL_NOME], situado em [IMOVEL_ENDERECO].

Características do imóvel:
- Quartos: [IMOVEL_QUARTOS]
- Banheiros: [IMOVEL_BANHEIROS]
- Capacidade: [IMOVEL_CAPACIDADE] pessoas

3. PRAZO E PERÍODO

Check-in: [CHECK_IN_DATA] às [CHECK_IN_HORA]
Check-out: [CHECK_OUT_DATA] às [CHECK_OUT_HORA]
Total: [NUMERO_NOITES]

Número de hóspedes: [NUMERO_HOSPEDES]

4. VALOR E FORMA DE PAGAMENTO

Valor Total: [VALOR_TOTAL]

Forma de Pagamento:
- Sinal (entrada): [VALOR_SINAL]
- Saldo: [VALOR_SALDO]
- Vencimento do saldo: [DATA_VENCIMENTO_SALDO]

5. DAS OBRIGAÇÕES DO LOCATÁRIO

[Suas cláusulas aqui...]

6. DISPOSIÇÕES FINAIS

[Suas cláusulas finais...]

Por estarem assim justos e contratados, as partes assinam o 
presente contrato em 2 (duas) vias de igual teor.

[CIDADE_ESTADO], [DATA_HOJE]

_________________________        _________________________
      LOCADOR                          LOCATÁRIO
```

## Passo 2: Salve como .DOCX

⚠️ **IMPORTANTE**: Salve o arquivo como `.docx` (não `.doc`)

## Passo 3: Anexe ao Imóvel

1. Acesse o sistema MyStay
2. Vá em **Menu > Imóveis**
3. Clique no imóvel que deseja configurar
4. Role até a seção **"Contrato do Imóvel"**
5. Clique em **"Escolher arquivo"** ou **"Adicionar contrato"**
6. Selecione o arquivo `.docx` que você criou
7. Clique em **"Salvar"**

## Passo 4: Teste o Contrato

1. Vá em **Menu > Hospedagens**
2. Crie ou edite uma hospedagem para o imóvel que configurou
3. Preencha todos os dados obrigatórios:
   - Nome e CPF do cliente
   - Datas de check-in e check-out
   - Valor total
4. Clique em **"Exportar Contrato"**
5. O sistema gerará o contrato com os dados preenchidos

## Dicas Importantes

### ✅ Faça

- Use formatação do Word (negrito, cores, etc.)
- Teste com uma hospedagem real antes de usar em produção
- Mantenha backup do template
- Use nomes de variáveis corretos (consulte CONTRACT_VARIABLES.md)

### ❌ Não Faça

- Salvar como `.doc` (formato antigo)
- Usar variáveis que não existem
- Esquecer de preencher dados obrigatórios antes de exportar

## Variáveis Mais Usadas

| Variável | Descrição | Exemplo |
|----------|-----------|---------|
| `[CLIENTE_NOME]` | Nome do cliente | "João da Silva" |
| `[CLIENTE_CPF]` | CPF do cliente | "123.456.789-00" |
| `[CHECK_IN_DATA]` | Data de entrada | "15/02/2026" |
| `[CHECK_OUT_DATA]` | Data de saída | "18/02/2026" |
| `[NUMERO_NOITES]` | Quantidade de noites | "3 noites" |
| `[VALOR_TOTAL]` | Valor total | "R$ 1.500,00" |
| `[IMOVEL_NOME]` | Nome do imóvel | "Ap Guarujá" |
| `[IMOVEL_ENDERECO]` | Endereço completo | "Rua ABC, nº 123..." |

📖 Lista completa em: [CONTRACT_VARIABLES.md](./CONTRACT_VARIABLES.md)

## Solução de Problemas

### Problema: "Dados obrigatórios faltando"
**Solução**: Preencha os dados do cliente (nome e CPF), datas e valor antes de exportar.

### Problema: "O imóvel não possui um template de contrato"
**Solução**: Anexe um template .docx no cadastro do imóvel.

### Problema: Variáveis não são substituídas
**Solução**: Verifique se o nome da variável está correto (entre colchetes e em maiúsculas).

### Problema: Formatação estranha no contrato gerado
**Solução**: Evite formatações muito complexas no Word. Use formatações simples.

## Suporte

Se precisar de ajuda:
1. Consulte o arquivo CONTRACT_VARIABLES.md
2. Consulte o arquivo CONTRACT_TEMPLATES.md
3. Verifique os logs do sistema
4. Entre em contato com o suporte técnico
