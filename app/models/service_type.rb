class ServiceType < ApplicationRecord
  belongs_to :tenant
  has_many :services, dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :tenant_id }
end
