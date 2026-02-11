# Variáveis Disponíveis para Templates de Contrato

Este documento lista todas as variáveis que podem ser usadas nos templates de contrato (.docx) do MyStay.

## Como Usar

Para usar uma variável no seu template de contrato, basta inserir o nome da variável entre colchetes: `[NOME_VARIAVEL]`

Exemplo: `[CLIENTE_NOME]` será substituído pelo nome completo do cliente.

## Variáveis Disponíveis

### Dados do Cliente/Hóspede

- `[CLIENTE_NOME]` ou `[NOME_CLIENTE]` - Nome completo do cliente
- `[CLIENTE_CPF]` ou `[CPF_CLIENTE]` - CPF do cliente
- `[CLIENTE_RG]` ou `[RG_CLIENTE]` - RG do cliente
- `[CLIENTE_EMAIL]` ou `[EMAIL_CLIENTE]` - E-mail do cliente
- `[CLIENTE_TELEFONE]` ou `[TELEFONE_CLIENTE]` - Telefone do cliente
- `[CLIENTE_ENDERECO]` ou `[ENDERECO_CLIENTE]` - Endereço completo do cliente
- `[CLIENTE_PROFISSAO]` ou `[PROFISSAO_CLIENTE]` - Profissão do cliente
- `[CLIENTE_ESTADO_CIVIL]` ou `[ESTADO_CIVIL_CLIENTE]` - Estado civil do cliente
- `[CLIENTE_NACIONALIDADE]` ou `[NACIONALIDADE_CLIENTE]` - Nacionalidade do cliente

### Dados da Hospedagem

- `[CHECK_IN_DATA]` ou `[DATA_CHECK_IN]` ou `[DATA_ENTRADA]` - Data de check-in (formato: DD/MM/YYYY)
- `[CHECK_OUT_DATA]` ou `[DATA_CHECK_OUT]` ou `[DATA_SAIDA]` - Data de check-out (formato: DD/MM/YYYY)
- `[CHECK_IN_HORA]` ou `[HORA_CHECK_IN]` ou `[HORA_ENTRADA]` - Horário de check-in (formato: HHhMM)
- `[CHECK_OUT_HORA]` ou `[HORA_CHECK_OUT]` ou `[HORA_SAIDA]` - Horário de check-out (formato: HHhMM)
- `[NUMERO_NOITES]` ou `[NOITES]` - Número de noites (ex: "3 noites")
- `[NUMERO_HOSPEDES]` ou `[HOSPEDES]` - Número de hóspedes
- `[VALOR_TOTAL]` ou `[TOTAL]` - Valor total da hospedagem (formato: R$ X.XXX,XX)
- `[VALOR_SINAL]` ou `[SINAL]` - Valor do sinal/entrada (formato: R$ X.XXX,XX)
- `[VALOR_SALDO]` ou `[SALDO]` - Valor do saldo restante (formato: R$ X.XXX,XX)
- `[DATA_VENCIMENTO_SALDO]` ou `[VENCIMENTO_SALDO]` - Data de vencimento do saldo
- `[OBSERVACOES]` ou `[OBSERVACOES_HOSPEDE]` - Observações sobre o hóspede
- `[DESCRICAO]` - Descrição da hospedagem

### Dados do Imóvel

- `[IMOVEL_NOME]` ou `[NOME_IMOVEL]` - Nome do imóvel
- `[IMOVEL_ENDERECO]` ou `[ENDERECO_IMOVEL]` - Endereço completo do imóvel
- `[IMOVEL_CIDADE]` ou `[CIDADE_IMOVEL]` - Cidade do imóvel
- `[IMOVEL_ESTADO]` ou `[ESTADO_IMOVEL]` - Estado do imóvel
- `[IMOVEL_CEP]` ou `[CEP_IMOVEL]` - CEP do imóvel
- `[IMOVEL_QUARTOS]` ou `[QUARTOS]` - Número de quartos
- `[IMOVEL_BANHEIROS]` ou `[BANHEIROS]` - Número de banheiros
- `[IMOVEL_CAPACIDADE]` ou `[CAPACIDADE_MAXIMA]` - Capacidade máxima de hóspedes
- `[IMOVEL_DESCRICAO]` ou `[DESCRICAO_IMOVEL]` - Descrição do imóvel

### Dados do Corretor/Vendedor

- `[VENDEDOR_NOME]` ou `[NOME_VENDEDOR]` ou `[CORRETOR_NOME]` - Nome do corretor/vendedor
- `[VENDEDOR_TELEFONE]` ou `[TELEFONE_VENDEDOR]` ou `[CORRETOR_TELEFONE]` - Telefone do corretor
- `[VENDEDOR_EMAIL]` ou `[EMAIL_VENDEDOR]` ou `[CORRETOR_EMAIL]` - E-mail do corretor

### Datas Atuais

- `[DATA_HOJE]` ou `[DATA_ATUAL]` - Data atual por extenso (ex: "11 de fevereiro de 2026")
- `[DIA_HOJE]` - Dia atual (número)
- `[MES_HOJE]` - Mês atual por extenso
- `[ANO_HOJE]` - Ano atual
- `[CIDADE_ESTADO]` - Cidade e estado do imóvel (formato: Cidade/UF)

## Exemplo de Uso

```
CONTRATO DE LOCAÇÃO POR TEMPORADA

LOCATÁRIO: [CLIENTE_NOME], [CLIENTE_NACIONALIDADE], [CLIENTE_ESTADO_CIVIL], 
portador do CPF nº [CLIENTE_CPF] e RG nº [CLIENTE_RG], 
residente em [CLIENTE_ENDERECO].

IMÓVEL: [IMOVEL_NOME], localizado em [IMOVEL_ENDERECO], 
com [IMOVEL_QUARTOS] quartos e [IMOVEL_BANHEIROS] banheiros.

PERÍODO: De [CHECK_IN_DATA] às [CHECK_IN_HORA] 
até [CHECK_OUT_DATA] às [CHECK_OUT_HORA], 
totalizando [NUMERO_NOITES].

VALOR: O valor total da locação é de [VALOR_TOTAL], 
sendo [VALOR_SINAL] de sinal e [VALOR_SALDO] de saldo, 
com vencimento em [DATA_VENCIMENTO_SALDO].

[CIDADE_ESTADO], [DATA_HOJE]
```

## Dados Obrigatórios

Para gerar o contrato, os seguintes dados são **obrigatórios**:

1. **Cliente**: Nome e CPF
2. **Hospedagem**: Datas de check-in e check-out, e valor total
3. **Imóvel**: Nome e endereço

Se algum desses dados estiver faltando, o sistema solicitará que sejam preenchidos antes de gerar o contrato.

## Observações

- Se uma variável não tiver valor, ela não será substituída e permanecerá como `[VARIAVEL]` no contrato gerado
- Os valores monetários são formatados automaticamente no padrão brasileiro (R$ 1.234,56)
- As datas são formatadas no padrão DD/MM/YYYY
- Você pode usar tanto a variável com prefixo quanto sufixo (ex: `[CLIENTE_NOME]` ou `[NOME_CLIENTE]`)
