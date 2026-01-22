class Service < ApplicationRecord
  self.table_name = :services

  belongs_to :tenant
  belongs_to :user
  belongs_to :customer, class_name: "Customer", optional: true
  belongs_to :property, optional: true
  belongs_to :seller, class_name: "Seller", optional: true
  belongs_to :service_type, optional: true
  has_many_attached :attachments, dependent: :purge_later

  validates :property_name, :guest_name, :guest_email, :check_in_date, :check_out_date, presence: true
  validates :check_out_date, comparison: { greater_than: :check_in_date }
  validates :booking_reference, uniqueness: { scope: :tenant_id }, allow_blank: true

  before_validation :assign_tenant_from_user
  before_validation :sync_names_from_associations
  before_create :generate_booking_reference
  validate :ensure_same_tenant_for_associations

  private

  def assign_tenant_from_user
    self.tenant_id ||= user&.tenant_id
  end

  def sync_names_from_associations
    if property.present?
      self.property_name = property.name
    end

    if customer.present?
      self.guest_name = customer.name
      self.guest_email = customer.email if customer.email.present?
    end
  end

  def generate_booking_reference
    self.booking_reference = SecureRandom.hex(6).upcase
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
end

Stay = Service
