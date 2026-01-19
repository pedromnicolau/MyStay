# frozen_string_literal: true

require "caracal"

class ContractGenerator
  include ActionView::Helpers::NumberHelper

  DOCX_CONTENT_TYPE = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"

  DEFAULT_LANDLORD = {
    name: ENV.fetch("CONTRACT_LANDLORD_NAME", "DANIEL CARLOS JARDIM NICOLAU"),
    nationality: ENV.fetch("CONTRACT_LANDLORD_NATIONALITY", "brasileiro"),
    rg: ENV.fetch("CONTRACT_LANDLORD_RG", "27.748.988"),
    cpf: ENV.fetch("CONTRACT_LANDLORD_CPF", "275.476.228-01"),
    city: ENV.fetch("CONTRACT_LANDLORD_CITY", "Araras/SP")
  }.freeze

  CHECK_IN_TIME = ENV.fetch("CONTRACT_CHECK_IN_TIME", "15h00")
  CHECK_OUT_TIME = ENV.fetch("CONTRACT_CHECK_OUT_TIME", "12h00")
  BALANCE_DAYS_BEFORE = ENV.fetch("CONTRACT_BALANCE_DAYS_BEFORE", 7).to_i
  DEFAULT_CAPACITY = ENV.fetch("CONTRACT_DEFAULT_CAPACITY", 6).to_i

  def initialize(stay, landlord: DEFAULT_LANDLORD)
    @stay = stay
    @customer = stay.customer
    @property = stay.property
    @landlord = landlord
  end

  def generate
    tmp_file = Tempfile.new([ "contrato-locacao-#{@stay.id}", ".docx" ], Rails.root.join("tmp"))
    docx = Caracal::Document.new(tmp_file.path)

    docx.h1 "CONTRATO DE LOCAÇÃO POR TEMPORADA"

    landlord_text = landlord_intro
    docx.p do
      text "LOCADOR: ", bold: true
      text landlord_text
    end

    tenant_text = tenant_intro
    docx.p do
      text "LOCATÁRIO: ", bold: true
      text tenant_text
    end

    docx.p "As partes acima identificadas têm, entre si, justo e contratado o presente Contrato de Locação por Temporada, que se regerá pelas cláusulas e condições seguintes:"

    docx.h2 "CLÁUSULA 1ª – DO IMÓVEL"
    docx.p property_clause

    docx.h2 "CLÁUSULA 2ª – DO OBJETO"
    docx.p "O objeto deste contrato é a locação por temporada do imóvel acima descrito, exclusivamente para fins de lazer e hospedagem do LOCATÁRIO e seus acompanhantes, sendo expressamente vedada a cessão, sublocação ou utilização para fins diversos."

    docx.h2 "CLÁUSULA 3ª – DO PERÍODO"
    docx.p period_clause

    docx.h2 "CLÁUSULA 4ª – DO VALOR E PAGAMENTO"
    docx.p value_clause

    docx.h2 "CLÁUSULA 5ª – DA CAPACIDADE MÁXIMA"
    docx.p capacity_clause

    docx.h2 "CLÁUSULA 6ª – DAS OBRIGAÇÕES DO LOCATÁRIO"
    obligations_paragraphs.each { |line| docx.p line }

    docx.h2 "CLÁUSULA 7ª – VAGA DA GARAGEM"
    docx.p garage_clause

    docx.h2 "CLÁUSULA 8ª – DA DESOCUPAÇÃO"
    docx.p "Findo o prazo contratual, o LOCATÁRIO se compromete a desocupar o imóvel no dia e horário previstos, sob pena de pagamento de multa diária equivalente a R$ 1.000,00 (mil reais) por dia de permanência indevida."

    docx.h2 "CLÁUSULA 9ª – DA RESCISÃO"
    docx.p "Em caso de desistência por parte do LOCATÁRIO após o pagamento do sinal, este não será devolvido. Em caso de força maior que impeça a estadia (doença grave, óbito ou eventos impeditivos comprovados), as partes poderão negociar nova data de uso, a critério do LOCADOR."

    docx.h2 "CLÁUSULA 10ª – DO FORO"
    docx.p "Para dirimir quaisquer controvérsias oriundas deste contrato, as partes elegem o foro da Comarca do Guarujá/SP, renunciando a qualquer outro, por mais privilegiado que seja."

    docx.p "E por estarem assim justas e contratadas, assinam o presente instrumento em 2 (duas) vias de igual teor e forma, juntamente com duas testemunhas."

    docx.p signature_line

    landlord_name = (@landlord && @landlord[:name]) || DEFAULT_LANDLORD[:name]
    guest_name = @stay.guest_name || "Hóspede"

    docx.p do
      text "LOCADOR: "
      text landlord_name
    end

    docx.p do
      text "LOCATÁRIO: _________________________________ "
      text guest_name
    end

    docx.p "TESTEMUNHAS:"
    docx.p "1) Nome: ______________________________ CPF: ______________________________"
    docx.p "2) Nome: ______________________________ CPF: ______________________________"

    docx.save
    tmp_file
  end

  def content_type
    DOCX_CONTENT_TYPE
  end

  private

  def landlord_intro
    [
      @landlord[:name],
      @landlord[:nationality],
      (@landlord[:rg] && "portador do RG nº #{@landlord[:rg]}") || nil,
      (@landlord[:cpf] && "CPF nº #{@landlord[:cpf]}") || nil,
      (@landlord[:city] && "residente e domiciliado em #{@landlord[:city]}") || nil
    ].compact.join(", ")
  end

  def tenant_intro
    return @stay.guest_name unless @customer

    [
      @customer.name,
      @customer.profession || "profissão não informada",
      @customer.marital_status || "estado civil não informado",
      (@customer.cpf && "CPF nº #{@customer.cpf}"),
      (@customer.rg && "RG nº #{@customer.rg}"),
      tenant_address
    ].compact.join(", ")
  end

  def property_clause
    "O LOCADOR é legítimo possuidor e/ou proprietário do imóvel localizado em #{property_full_address}, doravante denominado #{property_name}."
  end

  def period_clause
    "A locação terá início em #{format_date(@stay.check_in_date)} às #{CHECK_IN_TIME} e término em #{format_date(@stay.check_out_date)} às #{CHECK_OUT_TIME}, totalizando #{nights_text}."
  end

  def value_clause
    total = currency(@stay.total_due || 0)
    signal = currency(@stay.deposit_amount || 0)
    balance = currency(balance_due_value)

    "O valor total da locação é de #{total}, que será pago da seguinte forma: Sinal: #{signal} a título de reserva. Saldo: #{balance} deverá ser pago até #{format_date(balance_due_date)} (#{BALANCE_DAYS_BEFORE} dias antes da entrada)."
  end

  def capacity_clause
    "A hospedagem está limitada ao número máximo de #{capacity_text}. Caso seja constatado número superior ao permitido, o LOCADOR poderá rescindir o contrato, além de cobrar um valor de R$ 1.000,00 (mil reais) por pessoa excedente."
  end

  def obligations_paragraphs
    [
      "O LOCATÁRIO se obriga a:",
      "a) Utilizar o imóvel exclusivamente para fins de hospedagem;",
      "b) Zelar pela conservação do imóvel, móveis, utensílios e equipamentos, restituindo-os ao final da locação nas mesmas condições em que os recebeu;",
      "c) Cumprir o regulamento interno do condomínio, evitando ruídos excessivos e respeitando a vizinhança;",
      "d) Responder por danos ou prejuízos causados por si ou por seus acompanhantes, obrigando-se a indenizar o LOCADOR."
    ]
  end

  def garage_clause
    "O LOCATÁRIO e seus acompanhantes poderão acessar o prédio para descarregar malas e pertences; contudo, o veículo deverá permanecer estacionado exclusivamente no box nº C-3, localizado na Rua Mário Ribeiro, nº 706 – 3º Andar do Bloco B do Edifício Monsier Dany, conforme instruções do LOCADOR."
  end

  def signature_line
    "#{property_city_state}, #{today_in_portuguese}".strip
  end

  def tenant_address
    return nil unless @customer

    parts = [
      @customer.address,
      @customer.number,
      @customer.neighborhood,
      city_state(@customer.city, @customer.state),
      (@customer.zip && "CEP: #{@customer.zip}")
    ].compact
    parts.join(", ")
  end

  def property_full_address
    return @property.address unless @property

    [
      @property.address,
      @property.number,
      @property.neighborhood,
      city_state(@property.city, @property.state),
      (@property.zip && "CEP #{@property.zip}")
    ].compact.join(" – ")
  end

  def property_name
    @property&.name || @stay.property_name
  end

  def property_city_state
    if @property&.city
      city_state(@property.city, @property.state)
    else
      "Guarujá/SP"
    end
  end

  def city_state(city, state)
    return nil if city.blank? && state.blank?

    [ city, state ].compact.join("/")
  end

  def format_date(date)
    return "--/--/----" unless date

    I18n.l(date, format: "%d/%m/%Y")
  end

  def today_in_portuguese
    I18n.l(Date.current, format: "%d de %B de %Y", default: Date.current.strftime("%d de %B de %Y"))
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

    (@stay.check_in_date - BALANCE_DAYS_BEFORE.days).to_date
  end

  def capacity_text
    capacity = @stay.number_of_guests || DEFAULT_CAPACITY
    plural = capacity == 1 ? "pessoa" : "pessoas"
    "#{capacity} #{plural}"
  end
end
