class CrawlerJobsController < ApplicationController
  before_action :set_crawler_job, only: %i(export execute destroy)

  def index
    @crawler_jobs = CrawlerJob.order(created_at: :desc)
  end

  def new
    @crawler_job = CrawlerJob.new
  end

  def create
    @crawler_job = current_user.crawler_jobs.build(crawler_job_params)
    if params[:confirm]
      @crawler_job.save!
      redirect_to crawler_jobs_path, notice: 'ジョブを作成しました' and return
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
    filename = "#{@crawler_job.name}_#{@crawler_job.completed_at.strftime('%Y%m%d%H%M%S')}.csv"
    send_data @crawler_job.export_csv, filename: filename, type: 'text/csv; charset=shift_jis'
  end

  def execute
    message =
      if CrawlerJob.running.count.zero?
        @crawler_job.running!
        Thread.start do
          Thread.current["connection"] = ActiveRecord::Base.connection_pool.checkout()
          @crawler_job.execute_crawling
          ActiveRecord::Base.connection_pool.checkin(Thread.current["connection"])
        end
        { notice: 'クローリングを開始しました' }
      else
        { alert: '実行中のジョブがあるため開始できません' }
      end

    redirect_to crawler_jobs_path, message and return
  end

  def destroy
    @crawler_job.destroy!
    redirect_to crawler_jobs_path, notice: '削除しました' and return
  end

  private

  def set_crawler_job
    @crawler_job = CrawlerJob.find(params[:id])
  end

  def crawler_job_params
    params.fetch(:crawler_job, {}).permit(:site, :name, :url, :page_title, :total_count)
  end
end
