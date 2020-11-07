class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # DemoバージョンなのでNull可能
  validates_length_of :phone, :in => 10..11, :allow_nil => true
  validates_length_of :post_code, :is => 7, :allow_nil => true
end