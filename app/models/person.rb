class Person < ApplicationRecord
  self.inheritance_column = :_type_disabled

  belongs_to :tenant, inverse_of: :people
  belongs_to :user, inverse_of: :people
  has_many :services, -> { where(type: "Service") }, class_name: "Movement", dependent: :nullify, inverse_of: :customer
  has_many :stays, -> { where(type: "Stay") }, class_name: "Movement", dependent: :nullify, inverse_of: :customer
  has_many :movements, dependent: :nullify, inverse_of: :customer
  has_many :sold_movements, class_name: "Movement", foreign_key: "seller_id", dependent: :nullify, inverse_of: :seller
  has_one_attached :profile_image

  validates :name, :phone, presence: true
  validates :document, presence: true, uniqueness: { scope: :tenant_id }
  validates :rg, uniqueness: { scope: :tenant_id }, allow_blank: true
  validates :customer, :provider, :agent, inclusion: { in: [ true, false ] }
  validate :at_least_one_role
  validate :validate_document_format

  before_validation :assign_tenant_from_user
  before_save :normalize_city

  def as_json(options = {})
    attributes
  end

  private

  def assign_tenant_from_user
    self.tenant_id ||= user&.tenant_id
  end

  def normalize_city
    if city.present?
      self.city = city.split.map(&:capitalize).join(" ")
    end
  end

  def at_least_one_role
    return if customer || provider || agent

    errors.add(:base, "Selecione pelo menos um perfil")
  end

  def validate_document_format
    return if document.blank?

    cleaned = document.gsub(/\D/, "")

    if cleaned.length == 11
      validate_cpf_format(cleaned)
    elsif cleaned.length == 14
      validate_cnpj_format(cleaned)
    else
      errors.add(:document, "deve ser um CPF ou CNPJ válido")
    end
  end

  def validate_cpf_format(cpf)
    return errors.add(:document, "inválido") if cpf.chars.uniq.length == 1

    digits = cpf.chars.map(&:to_i)
    sum1 = (0..8).sum { |i| digits[i] * (10 - i) }
    digit1 = sum1 % 11 < 2 ? 0 : 11 - (sum1 % 11)

    sum2 = (0..9).sum { |i| digits[i] * (11 - i) }
    digit2 = sum2 % 11 < 2 ? 0 : 11 - (sum2 % 11)

    unless digits[9] == digit1 && digits[10] == digit2
      errors.add(:document, "inválido")
    end
  end

  def validate_cnpj_format(cnpj)
    return errors.add(:document, "inválido") if cnpj.chars.uniq.length == 1

    digits = cnpj.chars.map(&:to_i)
    weights1 = [ 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2 ]
    sum1 = (0..11).sum { |i| digits[i] * weights1[i] }
    digit1 = sum1 % 11 < 2 ? 0 : 11 - (sum1 % 11)

    weights2 = [ 6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2 ]
    sum2 = (0..12).sum { |i| digits[i] * weights2[i] }
    digit2 = sum2 % 11 < 2 ? 0 : 11 - (sum2 % 11)

    unless digits[12] == digit1 && digits[13] == digit2
      errors.add(:document, "inválido")
    end
  end
end
