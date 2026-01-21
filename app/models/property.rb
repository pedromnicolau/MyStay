class Property < ApplicationRecord
  belongs_to :user
  has_many_attached :attachments, dependent: :purge_later
  has_many :services, dependent: :nullify

  validates :name, presence: true
  validates :active, inclusion: { in: [ true, false ] }

  before_save :normalize_city

  private

  def normalize_city
    if city.present?
      self.city = city.split.map(&:capitalize).join(" ")
    end
  end
end
