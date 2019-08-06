class ExecuteCrawlerJob < ApplicationJob
  def perform(crawler_job_id)
    CrawlerJob.find_by(id: crawler_job_id)&.execute_crawling
  rescue => e
    ExceptionNotifier.notify_exception(e)
    raise e
  end
end
