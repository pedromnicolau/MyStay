class Movement < ApplicationRecord
  self.table_name = :movements

  belongs_to :tenant
  belongs_to :user
  belongs_to :customer, class_name: "Person", optional: true
  belongs_to :property, optional: true
  belongs_to :seller, class_name: "Person", optional: true
  belongs_to :service_type, optional: true
  has_many_attached :attachments, dependent: :purge_later

  validates :check_in_date, :check_out_date, presence: true
  validates :check_out_date, comparison: { greater_than: :check_in_date }

  before_validation :assign_tenant_from_user
  validate :ensure_same_tenant_for_associations
  validate :ensure_roles_for_associations

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
    if customer && !customer.customer
      errors.add(:customer_id, "deve ser um cliente")
    end

    if seller && !seller.agent
      errors.add(:seller_id, "deve ser um corretor")
    end
  end
end
