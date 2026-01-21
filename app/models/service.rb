class Service < ApplicationRecord
  self.table_name = :services

  belongs_to :user
  belongs_to :customer, class_name: "Customer", optional: true
  belongs_to :property, optional: true
  belongs_to :seller, class_name: "Seller", optional: true
  belongs_to :service_type, optional: true

  validates :property_name, :guest_name, :guest_email, :check_in_date, :check_out_date, presence: true
  validates :check_out_date, comparison: { greater_than: :check_in_date }

  before_validation :sync_names_from_associations
  before_create :generate_booking_reference

  private

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
end

Stay = Service
