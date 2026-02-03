class Movement < ApplicationRecord
  self.table_name = :movements

  belongs_to :tenant, inverse_of: :movements
  belongs_to :user, inverse_of: :movements
  belongs_to :customer, class_name: "Person", optional: true, inverse_of: :movements
  belongs_to :property, optional: true, inverse_of: :movements
  belongs_to :seller, class_name: "Person", optional: true, inverse_of: :sold_movements
  belongs_to :service_type, optional: true, inverse_of: :movements
  has_many_attached :attachments, dependent: :purge_later

  validates :check_in_date, :check_out_date, presence: true

  before_validation :assign_tenant_from_user
  validate :ensure_same_tenant_for_associations
  validate :ensure_roles_for_associations
  validate :validate_checkout_time
  validate :validate_no_time_conflicts

  # Garantir que o type sempre seja incluído no JSON
  def as_json(options = {})
    super(options).merge("type" => type)
  end

  private

  def assign_tenant_from_user
    self.tenant_id ||= user&.tenant_id
  end

  def ensure_same_tenant_for_associations
    assoc_tenant_ids = []
    assoc_tenant_ids << customer&.tenant_id if customer
    assoc_tenant_ids << property&.tenant_id if property
    assoc_tenant_ids << seller&.tenant_id if seller
    assoc_tenant_ids << service_type&.tenant_id if service_type

    assoc_tenant_ids.compact.each do |tid|
      errors.add(:tenant_id, "deve ser o mesmo do(s) registro(s) associado(s)") if tid != tenant_id
    end
  end

  def ensure_roles_for_associations
    # Para serviços (Service), customer_id é um prestador (provider)
    # Para hospedagens (Stay), customer_id é um cliente (customer)
    if customer
      if type == "Service"
        unless customer.provider
          errors.add(:customer_id, "deve ser um prestador")
        end
      else
        unless customer.customer
          errors.add(:customer_id, "deve ser um cliente")
        end
      end
    end

    if seller && !seller.agent
      errors.add(:seller_id, "deve ser um corretor")
    end
  end

  def validate_checkout_time
    return if check_in_date.blank? || check_out_date.blank?

    # Se checkout é antes do checkin, erro
    if check_out_date < check_in_date
      errors.add(:check_out_date, "não pode ser anterior à data de entrada")
      return
    end

    # Não aplicar validação de horários para Expenses
    return if type == "Expense"

    # Se é o mesmo dia, validar horários
    if check_in_date == check_out_date
      # Se não tem horários definidos, não permitir mesmo dia
      if check_in_time.blank? || check_out_time.blank?
        errors.add(:base, "Para check-in e check-out no mesmo dia, é necessário definir os horários")
        return
      end

      # Validar que check_out_time > check_in_time
      if check_out_time <= check_in_time
        errors.add(:check_out_time, "deve ser posterior ao horário de entrada quando no mesmo dia")
      end
    end
  end

  def validate_no_time_conflicts
    return if type == "Expense"
    return if property_id.blank? || check_in_date.blank? || check_out_date.blank?

    conflicting_movements = Movement.where(tenant_id: tenant_id, property_id: property_id)
                                   .where.not(id: id)
                                   .where.not(type: "Expense")
                                   .where("check_in_date <= ? AND check_out_date >= ?", check_out_date, check_in_date)

    conflicting_movements.each do |other|
      # Verificar se há conflito real de horário
      if time_overlap?(other)
        customer_name = other.customer&.name || "Reserva"

        # Formatar mensagem de data e horário
        if other.check_in_date == other.check_out_date
          date_range = "#{other.check_in_date.strftime('%d/%m/%Y')} (#{format_time(other.check_in_time)} - #{format_time(other.check_out_time)})"
        else
          date_range = "#{other.check_in_date.strftime('%d/%m/%Y')} (#{format_time(other.check_in_time)}) a #{other.check_out_date.strftime('%d/%m/%Y')} (#{format_time(other.check_out_time)})"
        end

        errors.add(:base, "Conflito de horário com reserva existente: #{customer_name} - #{date_range}")
        break # Mostrar apenas o primeiro conflito encontrado
      end
    end
  end

  def time_overlap?(other)
    # Criar timestamps combinando data + hora para comparação precisa
    self_start = combine_datetime(check_in_date, check_in_time)
    self_end = combine_datetime(check_out_date, check_out_time)
    other_start = combine_datetime(other.check_in_date, other.check_in_time)
    other_end = combine_datetime(other.check_out_date, other.check_out_time)

    # Verificar sobreposição: self começa antes de other terminar E self termina depois de other começar
    self_start < other_end && self_end > other_start
  end

  def combine_datetime(date, time)
    return date.to_time if time.blank?

    # Criar um DateTime combinando data e hora
    Time.zone.local(date.year, date.month, date.day, time.hour, time.min, time.sec)
  end

  def format_time(time)
    return "" if time.blank?
    time.strftime("%H:%M")
  end
end
