class Person < ApplicationRecord
  belongs_to :user

  TYPES = %w[Customer Seller Cleaner].freeze

  validates :name, :phone, :type, presence: true
  validates :cpf, presence: true, uniqueness: true
  validates :rg, uniqueness: true, allow_blank: true
  validates :type, inclusion: { in: TYPES }

  before_save :normalize_city

  private

  def normalize_city
    if city.present?
      self.city = city.split.map(&:capitalize).join(" ")
    end
  end
end
