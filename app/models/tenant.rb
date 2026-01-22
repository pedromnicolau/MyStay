class Tenant < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :people, dependent: :destroy
  has_many :properties, dependent: :destroy
  has_many :services, dependent: :destroy
  has_many :service_types, dependent: :destroy

  validates :name, presence: true
  validates :master_code, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9_-]+\z/, message: "deve conter apenas letras, números, hífen e underscore" }
end
