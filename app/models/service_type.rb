class ServiceType < ApplicationRecord
  belongs_to :tenant, inverse_of: :service_types
  has_many :services, -> { where(type: "Service") }, class_name: "Movement", dependent: :nullify, inverse_of: :service_type
  has_many :stays, -> { where(type: "Stay") }, class_name: "Movement", dependent: :nullify, inverse_of: :service_type
  has_many :movements, dependent: :nullify, inverse_of: :service_type

  validates :name, presence: true, uniqueness: { scope: :tenant_id }
end
