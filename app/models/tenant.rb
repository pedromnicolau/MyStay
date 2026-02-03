class Tenant < ApplicationRecord
  has_many :users, dependent: :destroy, inverse_of: :tenant
  has_many :people, dependent: :destroy, inverse_of: :tenant
  has_many :properties, dependent: :destroy, inverse_of: :tenant
  has_many :movements, dependent: :destroy, inverse_of: :tenant
  has_many :services, -> { where(type: "Service") }, class_name: "Movement", dependent: :destroy, inverse_of: :tenant
  has_many :stays, -> { where(type: "Stay") }, class_name: "Movement", dependent: :destroy, inverse_of: :tenant
  has_many :service_types, dependent: :destroy, inverse_of: :tenant

  validates :name, presence: true
  validates :master_code, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9_-]+\z/, message: "deve conter apenas letras, números, hífen e underscore" }
end
