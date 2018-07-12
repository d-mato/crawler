class CrawlerJobsController < ApplicationController
  def index
    @crawler_jobs = current_user.crawler_jobs.order(created_at: :desc)
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

    begin
      data = @crawler_job.crawler.parse_list(@crawler_job.url)
    rescue
      flash.now[:alert] = '無効なURLです'
      render :new and return
    end

    @crawler_job.page_title = data[:title]
    @crawler_job.total_count = data[:total_count]
    @confirm = true
    render :new
  end

  def export
    crawler_job = current_user.crawler_jobs.find(params[:id])
    filename = "#{crawler_job.page_title.delete(' ')}_#{crawler_job.completed_at.strftime('%Y%m%d%H%M%S')}.csv"
    send_data crawler_job.export_csv, filename: filename, type: 'text/csv; charset=shift_jis'
  end

  def destroy
    crawler_job = current_user.crawler_jobs.find(params[:id])
    crawler_job.destroy!
    redirect_to crawler_jobs_path and return
  end

  private

  def crawler_job_params
    params.fetch(:crawler_job, {}).permit(:site, :url, :page_title, :total_count)
  end
end
