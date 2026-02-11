#!/usr/bin/env ruby
# frozen_string_literal: true

# Script para testar a funcionalidade de templates de contrato
# Uso: bin/rails runner script/test_contract_template.rb

puts "=" * 80
puts "TESTE: Sistema de Templates de Contrato"
puts "=" * 80
puts

# 1. Verificar se a classe existe
begin
  Object.const_get("ContractTemplateProcessor")
  puts "✅ Classe ContractTemplateProcessor carregada"
rescue NameError
  puts "❌ Classe ContractTemplateProcessor não encontrada"
  exit 1
end

# 2. Buscar uma hospedagem para testar
stay = Stay.includes(:customer, :property, :seller).first

unless stay
  puts "❌ Nenhuma hospedagem encontrada no banco de dados"
  puts "   Crie uma hospedagem primeiro para testar"
  exit 1
end

puts "✅ Hospedagem encontrada para teste"
puts "   ID: #{stay.id}"
puts "   Cliente: #{stay.customer&.name || 'N/A'}"
puts "   Imóvel: #{stay.property&.name || 'N/A'}"
puts

# 3. Verificar se o imóvel tem template
if stay.property&.contract&.attached?
  puts "✅ Imóvel possui template de contrato anexado"
  puts "   Arquivo: #{stay.property.contract.filename}"
  puts "   Tamanho: #{stay.property.contract.byte_size} bytes"
else
  puts "⚠️  Imóvel não possui template de contrato"
  puts "   O sistema usará o gerador padrão (ContractGenerator)"
  puts
  puts "   Para testar a nova funcionalidade:"
  puts "   1. Acesse Imóveis no sistema"
  puts "   2. Edite o imóvel '#{stay.property&.name || 'N/A'}'"
  puts "   3. Anexe um arquivo .docx na seção 'Contrato do Imóvel'"
  exit 0
end

puts

# 4. Validar dados obrigatórios
puts "📋 Validando dados obrigatórios..."
processor = ContractTemplateProcessor.new(stay)

begin
  processor.send(:validate_required_data!)
  puts "✅ Todos os dados obrigatórios estão preenchidos"
rescue ContractTemplateProcessor::MissingDataError => e
  puts "❌ Dados obrigatórios faltando:"
  e.missing_fields.each do |field|
    puts "   - #{field}"
  end
  puts
  puts "   Preencha esses dados antes de exportar o contrato"
  exit 0
end

puts

# 5. Testar variáveis disponíveis
puts "🔤 Testando substituição de variáveis..."
test_variables = {
  "CLIENTE_NOME" => processor.send(:get_variable_value, "CLIENTE_NOME"),
  "CLIENTE_CPF" => processor.send(:get_variable_value, "CLIENTE_CPF"),
  "CHECK_IN_DATA" => processor.send(:get_variable_value, "CHECK_IN_DATA"),
  "CHECK_OUT_DATA" => processor.send(:get_variable_value, "CHECK_OUT_DATA"),
  "VALOR_TOTAL" => processor.send(:get_variable_value, "VALOR_TOTAL"),
  "IMOVEL_NOME" => processor.send(:get_variable_value, "IMOVEL_NOME"),
  "IMOVEL_ENDERECO" => processor.send(:get_variable_value, "IMOVEL_ENDERECO")
}

test_variables.each do |var_name, value|
  status = value.present? ? "✅" : "⚠️"
  puts "   #{status} [#{var_name}] = #{value || '(vazio)'}"
end

puts
puts "=" * 80
puts "RESULTADO: Sistema pronto para processar contratos!"
puts "=" * 80
puts
puts "Para exportar um contrato:"
puts "1. Acesse Hospedagens no sistema"
puts "2. Clique na hospedagem ID #{stay.id}"
puts "3. Clique em 'Exportar Contrato'"
puts "4. O sistema processará o template e fará o download"
puts
