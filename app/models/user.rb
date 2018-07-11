class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :trackable, :validatable

  has_many :crawler_jobs
end
