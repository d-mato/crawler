class CrawlerJobsController < ApplicationController
  before_action :set_crawler_job, only: %i(export cancel restart destroy)

  def index
    @crawler_jobs = CrawlerJob.includes(:fetched_web_pages).order(created_at: :desc)
  end

  def new
    @crawler_job = CrawlerJob.new
  end

  def confirm
    @crawler_job = CrawlerJob.new(crawler_job_params)
    if @crawler_job.valid? && @crawler_job.fetch_list_specs
      render :confirm and return
    end

    flash.now[:alert] = @crawler_job.errors.full_messages.join("\n")
    render :new
  end

  def create
    @crawler_job = CrawlerJob.new(crawler_job_params)
    @crawler_job.save!
    ExecuteCrawlerJob.perform_later(@crawler_job.id)
    redirect_to crawler_jobs_path, notice: 'ジョブを作成しました'
  end

  def export
    filename = "#{@crawler_job.name}_#{@crawler_job.completed_at.strftime('%Y%m%d%H%M%S')}.csv"
    send_data @crawler_job.export_csv, filename: filename, type: 'text/csv; charset=shift_jis'
  end

  def cancel
    @crawler_job.canceled!
    redirect_to crawler_jobs_path, { notice: 'ジョブをキャンセルしました' }
  end

  def restart
    @crawler_job.waiting!
    ExecuteCrawlerJob.perform_later(@crawler_job.id)
    redirect_to crawler_jobs_path, notice: 'ジョブを再登録しました'
  end

  def destroy
    if @crawler_job.destroy
      redirect_to crawler_jobs_path, notice: '削除しました' and return
    end
    redirect_to crawler_jobs_path, alert: @crawler_job.errors.full_messages.join("\n")
  end

  private

  def set_crawler_job
    @crawler_job = CrawlerJob.find(params[:id])
  end

  def crawler_job_params
    params.fetch(:crawler_job, {}).permit(:site, :name, :url, :page_title, :total_count)
  end
end
