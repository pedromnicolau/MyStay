class Stay < ApplicationRecord
  belongs_to :user

  validates :property_name, :guest_name, :guest_email, :check_in_date, :check_out_date, presence: true
  validates :check_out_date, comparison: { greater_than: :check_in_date }
  validate :check_in_date_cannot_be_in_past

  before_create :generate_booking_reference

  enum status: { pending: "pending", confirmed: "confirmed", cancelled: "cancelled", completed: "completed" }

  private

  def check_in_date_cannot_be_in_past
    if check_in_date.present? && check_in_date < Date.today
      errors.add(:check_in_date, "can't be in the past")
    end
  end

  def generate_booking_reference
    self.booking_reference = SecureRandom.hex(6).upcase
  end
end
