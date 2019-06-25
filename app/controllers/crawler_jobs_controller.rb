class CrawlerJobsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_crawler_job, only: %i(show export cancel restart destroy)

  def index
    @crawler_jobs = CrawlerJob.includes(:user, :web_pages).order(created_at: :desc).page(params[:page]).per(50)
  end

  def show
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
    @crawler_job.user = current_user
    @crawler_job.save!
    ExecuteCrawlerJob.perform_later(@crawler_job.id)
    redirect_to crawler_jobs_path, notice: 'ジョブを作成しました'
  end

  def export
    filename = "#{@crawler_job.name}_#{@crawler_job.completed_at.strftime('%Y%m%d%H%M%S')}.csv"
    csv = @crawler_job.export_csv
    send_file csv.path, filename: filename, type: 'text/csv; charset=utf-8'
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
    params.fetch(:crawler_job, {}).permit!
  end
end
