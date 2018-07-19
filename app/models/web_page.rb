class WebPage < ApplicationRecord
  belongs_to :crawler_job

  def fetched?
    fetched_at? && body.present?
  end

  def fetch_contents
    body = open(url).read.force_encoding('UTF-8')
    update!(body: body)
    touch :fetched_at
  rescue => e
    update!(error_message: e.message)
  end
end
