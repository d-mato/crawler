class CrawlerJobsController < ApplicationController
  def index
    @crawler_jobs = current_user.crawler_jobs
  end

  def new
    @crawler_job = CrawlerJob.new
  end

  def create
    @crawler_job = current_user.crawler_jobs.build(crawler_job_params)
    if params[:confirm]
      @crawler_job.save!
      redirect_to crawler_jobs_path and return
    end

    crawler = @crawler_job.crawler_klass.new
    data = crawler.parse_list(@crawler_job.url)
    @target_title = data[:title]
    @target_total_count = data[:total_count]
    @confirm = true
    render :new
  end

  private

  def crawler_job_params
    params.fetch(:crawler_job, {}).permit(:site, :url)
  end
end
