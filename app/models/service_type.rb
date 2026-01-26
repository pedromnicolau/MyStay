class ServiceType < ApplicationRecord
  belongs_to :tenant
  has_many :services, -> { where(type: "Service") }, dependent: :nullify
  has_many :stays, class_name: "Stay", dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :tenant_id }
end
