class Person < ApplicationRecord
  self.inheritance_column = :_type_disabled

  belongs_to :tenant
  belongs_to :user
  has_many :services, dependent: :nullify

  TYPES = %w[Customer Seller Cleaner Provider].freeze

  validates :name, :phone, :type, presence: true
  validates :cpf, presence: true, uniqueness: { scope: :tenant_id }
  validates :rg, uniqueness: { scope: :tenant_id }, allow_blank: true
  validates :type, inclusion: { in: TYPES }

  before_validation :assign_tenant_from_user
  before_save :normalize_city

  private

  def assign_tenant_from_user
    self.tenant_id ||= user&.tenant_id
  end

  def normalize_city
    if city.present?
      self.city = city.split.map(&:capitalize).join(" ")
    end
  end
end
