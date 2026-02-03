class Property < ApplicationRecord
  belongs_to :tenant, inverse_of: :properties
  belongs_to :user, inverse_of: :properties
  has_many_attached :attachments, dependent: :purge_later
  has_one_attached :contract, dependent: :purge_later
  has_many :services, -> { where(type: "Service") }, class_name: "Movement", dependent: :nullify, inverse_of: :property
  has_many :stays, -> { where(type: "Stay") }, class_name: "Movement", dependent: :nullify, inverse_of: :property
  has_many :movements, dependent: :nullify, inverse_of: :property

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
