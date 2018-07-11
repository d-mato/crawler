class CrawlerJob < ApplicationRecord
  belongs_to :user
  has_many :web_pages

  enum status: %w[waiting running failed completed].map { |v| [v, v] }.to_h

  before_create do
    self.status = :waiting
  end
end
