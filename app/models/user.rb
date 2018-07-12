class User < ApplicationRecord
  devise :database_authenticatable, :trackable, :validatable

  has_many :crawler_jobs
end
