class Person < ApplicationRecord
  self.inheritance_column = :_type_disabled

  belongs_to :tenant
  belongs_to :user
  has_many :services, -> { where(type: "Service") }, dependent: :nullify
  has_many :stays, class_name: "Stay", dependent: :nullify
  has_one_attached :profile_image

  TYPES = %w[Customer Seller Cleaner Provider].freeze

  validates :name, :phone, :type, presence: true
  validates :cpf, presence: true, uniqueness: { scope: :tenant_id }
  validates :rg, uniqueness: { scope: :tenant_id }, allow_blank: true
  validates :type, inclusion: { in: TYPES }

  before_validation :assign_tenant_from_user
  before_save :normalize_city
  after_save :clear_profile_image_cache

  def as_json(options = {})
    attributes.merge({
      "profile_image" => profile_image_url
    })
  end

  def profile_image_url
    return @profile_image_url if defined?(@profile_image_url)
    @profile_image_url = profile_image.attached? ? Rails.application.routes.url_helpers.url_for(profile_image) : nil
  end

  private

  def assign_tenant_from_user
    self.tenant_id ||= user&.tenant_id
  end

  def normalize_city
    if city.present?
      self.city = city.split.map(&:capitalize).join(" ")
    end
  end

  def clear_profile_image_cache
    @profile_image_url = nil
  end
end
