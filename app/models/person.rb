class Person < ApplicationRecord
  belongs_to :user

  TYPES = %w[Customer Seller Cleaner].freeze

  validates :name, :phone, :type, presence: true
  validates :cpf, presence: true, uniqueness: { scope: :user_id }
  validates :type, inclusion: { in: TYPES }
end
