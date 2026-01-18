class Property < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :active, inclusion: { in: [ true, false ] }
end
