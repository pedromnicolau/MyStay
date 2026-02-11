# Sistema de Contratos com Templates Personalizados

## Visão Geral

O MyStay agora suporta templates de contrato personalizados por imóvel. Você pode criar seu próprio modelo de contrato em Word (.docx) e o sistema automaticamente substituirá as variáveis pelos dados da hospedagem.

## Como Funciona

1. **Crie seu template**: Crie um documento Word (.docx) com o layout do seu contrato
2. **Use variáveis**: Insira variáveis no formato `[NOME_VARIAVEL]` onde quiser que dados sejam substituídos
3. **Anexe ao imóvel**: No cadastro do imóvel, anexe o arquivo do contrato
4. **Exporte contratos**: Ao exportar um contrato de hospedagem, o sistema usará o template do imóvel

## Passo a Passo

### 1. Criar o Template

1. Abra o Microsoft Word ou LibreOffice Writer
2. Crie o layout do seu contrato (cabeçalho, cláusulas, etc.)
3. Onde você quer que dados dinâmicos apareçam, insira as variáveis entre colchetes

Exemplo:
```
CONTRATO DE LOCAÇÃO POR TEMPORADA

LOCATÁRIO: [CLIENTE_NOME], brasileiro, casado, portador do CPF nº [CLIENTE_CPF]

Pelo presente instrumento particular, as partes acima qualificadas têm entre si, 
justo e contratado a locação do imóvel [IMOVEL_NOME], localizado em [IMOVEL_ENDERECO].

Período: [CHECK_IN_DATA] às [CHECK_IN_HORA] até [CHECK_OUT_DATA] às [CHECK_OUT_HORA]

Valor: [VALOR_TOTAL]
```

### 2. Variáveis Disponíveis

Consulte o arquivo [CONTRACT_VARIABLES.md](./CONTRACT_VARIABLES.md) para ver todas as variáveis disponíveis.

Principais variáveis:
- Cliente: `[CLIENTE_NOME]`, `[CLIENTE_CPF]`, `[CLIENTE_EMAIL]`, etc.
- Hospedagem: `[CHECK_IN_DATA]`, `[CHECK_OUT_DATA]`, `[VALOR_TOTAL]`, etc.
- Imóvel: `[IMOVEL_NOME]`, `[IMOVEL_ENDERECO]`, `[IMOVEL_QUARTOS]`, etc.

### 3. Anexar o Template ao Imóvel

1. Acesse **Imóveis** no menu
2. Edite o imóvel desejado
3. Na seção **"Contrato"**, clique em **"Escolher arquivo"**
4. Selecione seu template .docx
5. Salve o imóvel

### 4. Exportar Contrato

1. Acesse **Hospedagens**
2. Clique em uma hospedagem para ver os detalhes
3. Clique em **"Exportar Contrato"**
4. O sistema processará o template e fará o download automaticamente

## Validação de Dados

O sistema valida se todos os dados obrigatórios estão preenchidos antes de gerar o contrato:

**Dados obrigatórios:**
- Cliente: Nome e CPF
- Hospedagem: Datas de check-in/check-out e valor total
- Imóvel: Nome e endereço

Se faltar algum dado, você receberá uma mensagem informando o que precisa ser preenchido.

## Fallback para Gerador Padrão

Se um imóvel não tiver um template de contrato anexado, o sistema usará automaticamente o gerador de contrato padrão (aquele que já existia anteriormente).

## Dicas

1. **Teste seu template**: Crie uma hospedagem de teste e exporte o contrato para verificar se ficou como esperado
2. **Use formatação do Word**: Negrito, itálico, cores, etc. serão preservados
3. **Organize bem**: Use títulos, numeração de cláusulas, tabelas - tudo é preservado
4. **Salve backups**: Mantenha cópias dos seus templates

## Exemplo Completo

Veja um exemplo de template na pasta `docs/examples/` (se disponível).

## Suporte Técnico

Se tiver problemas:
1. Verifique se o arquivo é .docx (não .doc)
2. Verifique se as variáveis estão com os nomes corretos (case-sensitive)
3. Verifique se todos os dados obrigatórios estão cadastrados
4. Consulte os logs do sistema em caso de erro

## Tecnologia

O sistema utiliza:
- **rubyzip**: Para manipular arquivos .docx (que são ZIPs)
- **Nokogiri**: Para processar o XML interno do documento
- **Active Storage**: Para armazenar os templates

Todas as variáveis são substituídas mantendo a formatação original do documento.
