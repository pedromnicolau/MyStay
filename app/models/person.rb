class Person < ApplicationRecord
  self.inheritance_column = :_type_disabled

  belongs_to :user
  has_many :services, dependent: :nullify

  TYPES = %w[Customer Seller Cleaner Provider].freeze

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
