class User < ApplicationRecord
  validates_presence_of :name, :street, :city, :state, :zip,
                        :email, :password, :role, :enabled
  validates_uniqueness_of :email

  has_many :orders
  has_many :items
end
