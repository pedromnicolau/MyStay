class Property < ApplicationRecord
  belongs_to :tenant
  belongs_to :user
  has_many_attached :attachments, dependent: :purge_later
  has_many :services, -> { where(type: "Service") }, dependent: :nullify
  has_many :stays, class_name: "Stay", dependent: :nullify

  validates :name, presence: true
  validates :active, inclusion: { in: [ true, false ] }

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
