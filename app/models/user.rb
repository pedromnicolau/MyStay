class User < ApplicationRecord
  has_secure_password validations: false
  has_many :services, dependent: :destroy
  has_many :people, dependent: :destroy
  has_many :properties, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, on: :create
  validates :password, length: { minimum: 6 }, allow_blank: true
  validates :password_confirmation, presence: true, if: :password_present?

  private

  def password_present?
    password.present?
  end
end
