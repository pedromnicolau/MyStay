class ServiceType < ApplicationRecord
  has_many :services, dependent: :nullify

  validates :name, presence: true, uniqueness: true
end
