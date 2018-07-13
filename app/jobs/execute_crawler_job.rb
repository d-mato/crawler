class ExecuteCrawlerJob < ApplicationJob
  def perform(crawler_job_id)
    crawler_job = CrawlerJob.find(crawler_job_id)
    crawler_job.execute_crawling
  end
end
