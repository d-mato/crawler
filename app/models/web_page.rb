class WebPage < ApplicationRecord
  belongs_to :crawler_job

  def fetch_contents
    update!(body: open(url).read)
    touch :fetched_at
  rescue => e
    update!(error_message: e.message)
  end
end