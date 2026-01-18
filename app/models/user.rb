class User < ApplicationRecord
  has_secure_password
  has_many :stays, dependent: :destroy
  has_many :people, dependent: :destroy
  has_many :properties, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, on: :create
end
