class User < ApplicationRecord
  belongs_to :tenant

  has_one_attached :profile_image
  has_secure_password validations: false
  has_many :movements, dependent: :destroy
  has_many :services, -> { where(type: "Service") }, dependent: :destroy
  has_many :stays, class_name: "Stay", dependent: :destroy
  has_many :people, dependent: :destroy
  has_many :properties, dependent: :destroy

  validates :email, presence: true, uniqueness: { scope: :tenant_id }
  validates :password, presence: true, on: :create
  validates :password, length: { minimum: 6 }, allow_blank: true
  validates :password_confirmation, presence: true, if: :password_present?

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

  def password_present?
    password.present?
  end

  def clear_profile_image_cache
    @profile_image_url = nil
  end
end
