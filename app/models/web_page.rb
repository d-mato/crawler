class WebPage < ApplicationRecord
  belongs_to :crawler_job

  scope :fetched, -> { where.not(fetched_at: nil, body: '') }

  def fetched?
    fetched_at? && body.present?
  end

  def fetch_contents
    update!(body: open(url).read)
    touch :fetched_at
  rescue => e
    update!(error_message: e.message)
  end
end
