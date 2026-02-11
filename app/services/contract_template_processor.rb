# frozen_string_literal: true

require "zip"
require "nokogiri"

class ContractTemplateProcessor
  include ActionView::Helpers::NumberHelper

  class MissingDataError < StandardError
    attr_reader :missing_fields

    def initialize(message, missing_fields = [])
      super(message)
      @missing_fields = missing_fields
    end
  end

  def initialize(stay)
    @stay = stay
    @customer = stay.customer
    @property = stay.property
    @seller = stay.seller
  end

  def process
    # Verificar se o imóvel tem um template de contrato anexado
    unless @property&.contract&.attached?
      raise MissingDataError.new("O imóvel não possui um template de contrato anexado")
    end

    # Verificar dados obrigatórios
    validate_required_data!

    # Baixar o template do Active Storage
    template_file = download_template

    # Processar o template
    output_file = process_template(template_file)

    output_file
  ensure
    template_file&.close!
    template_file&.unlink if template_file&.path
  end

  def content_type
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
  end

  private

  def validate_required_data!
    missing = []

    # Verificar dados do cliente
    missing << "Nome do cliente" if @customer.blank? || @customer.name.blank?
    missing << "CPF do cliente" if @customer.blank? || @customer.document.blank?

    # Verificar dados da hospedagem
    missing << "Data de check-in" if @stay.check_in_date.blank?
    missing << "Data de check-out" if @stay.check_out_date.blank?
    missing << "Valor total" if @stay.total_due.blank? || @stay.total_due.zero?

    # Verificar dados do imóvel
    missing << "Nome do imóvel" if @property.blank? || @property.name.blank?
    missing << "Endereço do imóvel" if @property.blank? || @property.address.blank?

    if missing.any?
      raise MissingDataError.new(
        "Dados obrigatórios faltando para gerar o contrato: #{missing.join(', ')}",
        missing
      )
    end
  end

  def download_template
    temp_file = Tempfile.new([ "contract-template-#{@property.id}", ".docx" ], Rails.root.join("tmp"))
    @property.contract.blob.download do |chunk|
      temp_file.write(chunk)
    end
    temp_file.rewind
    temp_file
  end

  def process_template(template_file)
    output_file = Tempfile.new([ "contract-output-#{@stay.id}", ".docx" ], Rails.root.join("tmp"))

    Zip::File.open(template_file.path) do |zip_in|
      Zip::OutputStream.open(output_file.path) do |zip_out|
        zip_in.each do |entry|
          # Ler o conteúdo do arquivo
          content = entry.get_input_stream.read

          # Processar apenas o document.xml (conteúdo principal do Word)
          if entry.name == "word/document.xml"
            content = process_xml_content(content)
          end

          # Escrever no novo arquivo
          zip_out.put_next_entry(entry.name)
          zip_out.write(content)
        end
      end
    end

    output_file
  end

  def process_xml_content(xml_content)
    doc = Nokogiri::XML(xml_content)

    # Encontrar todos os textos no documento
    text_nodes = doc.xpath("//w:t", "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main")

    # Processar cada nó de texto
    text_nodes.each do |node|
      text = node.content
      # Substituir todas as variáveis [NOME_VARIAVEL]
      new_text = replace_variables(text)
      node.content = new_text if new_text != text
    end

    doc.to_xml
  end

  def replace_variables(text)
    # Substituir todas as ocorrências de [VARIAVEL]
    text.gsub(/\[([^\]]+)\]/) do |match|
      variable_name = $1.strip.upcase
      get_variable_value(variable_name) || match
    end
  end

  def get_variable_value(variable_name)
    case variable_name
    # Dados do cliente
    when "CLIENTE_NOME", "NOME_CLIENTE"
      @customer&.name
    when "CLIENTE_CPF", "CPF_CLIENTE"
      @customer&.document
    when "CLIENTE_RG", "RG_CLIENTE"
      @customer&.rg
    when "CLIENTE_EMAIL", "EMAIL_CLIENTE"
      @customer&.email
    when "CLIENTE_TELEFONE", "TELEFONE_CLIENTE"
      @customer&.phone
    when "CLIENTE_ENDERECO", "ENDERECO_CLIENTE"
      customer_address
    when "CLIENTE_PROFISSAO", "PROFISSAO_CLIENTE"
      @customer&.profession
    when "CLIENTE_ESTADO_CIVIL", "ESTADO_CIVIL_CLIENTE"
      @customer&.marital_status
    when "CLIENTE_NACIONALIDADE", "NACIONALIDADE_CLIENTE"
      @customer&.nationality

    # Dados da hospedagem
    when "CHECK_IN_DATA", "DATA_CHECK_IN", "DATA_ENTRADA"
      format_date(@stay.check_in_date)
    when "CHECK_OUT_DATA", "DATA_CHECK_OUT", "DATA_SAIDA"
      format_date(@stay.check_out_date)
    when "CHECK_IN_HORA", "HORA_CHECK_IN", "HORA_ENTRADA"
      format_time(@stay.check_in_time) || "15h00"
    when "CHECK_OUT_HORA", "HORA_CHECK_OUT", "HORA_SAIDA"
      format_time(@stay.check_out_time) || "12h00"
    when "NUMERO_NOITES", "NOITES"
      nights_text
    when "NUMERO_HOSPEDES", "HOSPEDES"
      @stay.number_of_guests&.to_s || "0"
    when "VALOR_TOTAL", "TOTAL"
      currency(@stay.total_due || 0)
    when "VALOR_SINAL", "SINAL"
      currency(@stay.deposit_amount || 0)
    when "VALOR_SALDO", "SALDO"
      currency(balance_due_value)
    when "DATA_VENCIMENTO_SALDO", "VENCIMENTO_SALDO"
      format_date(balance_due_date)
    when "OBSERVACOES", "OBSERVACOES_HOSPEDE"
      @stay.guest_note
    when "DESCRICAO"
      @stay.description

    # Dados do imóvel
    when "IMOVEL_NOME", "NOME_IMOVEL"
      @property&.name
    when "IMOVEL_ENDERECO", "ENDERECO_IMOVEL"
      property_full_address
    when "IMOVEL_CIDADE", "CIDADE_IMOVEL"
      @property&.city
    when "IMOVEL_ESTADO", "ESTADO_IMOVEL"
      @property&.state
    when "IMOVEL_CEP", "CEP_IMOVEL"
      @property&.zip
    when "IMOVEL_QUARTOS", "QUARTOS"
      @property&.bedrooms&.to_s
    when "IMOVEL_BANHEIROS", "BANHEIROS"
      @property&.bathrooms&.to_s
    when "IMOVEL_CAPACIDADE", "CAPACIDADE_MAXIMA"
      @property&.max_guests&.to_s
    when "IMOVEL_DESCRICAO", "DESCRICAO_IMOVEL"
      @property&.description

    # Dados do corretor/vendedor
    when "VENDEDOR_NOME", "NOME_VENDEDOR", "CORRETOR_NOME"
      @seller&.name
    when "VENDEDOR_TELEFONE", "TELEFONE_VENDEDOR", "CORRETOR_TELEFONE"
      @seller&.phone
    when "VENDEDOR_EMAIL", "EMAIL_VENDEDOR", "CORRETOR_EMAIL"
      @seller&.email

    # Data atual
    when "DATA_HOJE", "DATA_ATUAL"
      today_in_portuguese
    when "DIA_HOJE"
      Date.current.day.to_s
    when "MES_HOJE"
      I18n.l(Date.current, format: "%B")
    when "ANO_HOJE"
      Date.current.year.to_s

    # Cidade/Estado atual (do imóvel)
    when "CIDADE_ESTADO"
      property_city_state

    else
      nil # Retorna nil para manter a variável original se não encontrada
    end
  end

  def customer_address
    return nil unless @customer

    parts = [
      @customer.address,
      (@customer.number && "nº #{@customer.number}"),
      @customer.neighborhood,
      city_state(@customer.city, @customer.state),
      (@customer.zip && "CEP #{@customer.zip}")
    ].compact
    parts.join(", ")
  end

  def property_full_address
    return @property.address unless @property

    [
      @property.address,
      (@property.number && "nº #{@property.number}"),
      @property.neighborhood,
      city_state(@property.city, @property.state),
      (@property.zip && "CEP #{@property.zip}")
    ].compact.join(", ")
  end

  def property_city_state
    if @property&.city
      city_state(@property.city, @property.state)
    else
      ""
    end
  end

  def city_state(city, state)
    return nil if city.blank? && state.blank?
    [ city, state ].compact.join("/")
  end

  def format_date(date)
    return "" unless date
    I18n.l(date, format: "%d/%m/%Y")
  end

  def format_time(time)
    return nil unless time
    parts = time.to_s.split(":")
    "#{parts[0]}h#{parts[1]}"
  end

  def today_in_portuguese
    I18n.l(Date.current, format: "%d de %B de %Y")
  end

  def currency(value)
    number_to_currency(value, unit: "R$", separator: ",", delimiter: ".", precision: 2)
  end

  def nights_text
    nights = total_nights
    plural = nights == 1 ? "noite" : "noites"
    "#{nights} #{plural}"
  end

  def total_nights
    return 0 unless @stay.check_in_date && @stay.check_out_date
    (@stay.check_out_date - @stay.check_in_date).to_i
  end

  def balance_due_value
    total = @stay.total_due || 0
    deposit = @stay.deposit_amount || 0
    [ total - deposit, 0 ].max
  end

  def balance_due_date
    return Date.current unless @stay.check_in_date
    days_before = ENV.fetch("CONTRACT_BALANCE_DAYS_BEFORE", 7).to_i
    (@stay.check_in_date - days_before.days).to_date
  end
end
