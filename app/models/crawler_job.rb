require 'csv'

class CrawlerJob < ApplicationRecord
  class Cancel < StandardError; end
  class CrawlerNotFound < StandardError; end
  WAIT_TIME = 10

  belongs_to :user, optional: true
  has_many :web_pages, dependent: :destroy

  enum status: %w[waiting running canceled failed completed].map { |v| [v, v] }.to_h

  before_validation do
    self.name = name.gsub(/\s|　/, '_').strip
  end

  before_create do
    self.status = :waiting
  end

  before_destroy do
    if running?
      errors[:base] << '実行中のジョブは削除できません'
      throw :abort
    end
  end

  validates :site, presence: true
  validates :name, presence: true
  validate do
    errors[:base] << 'URLとURLリストのどちらかを入力してください' if url.blank? && url_list.blank?
  end
  validate do
    crawler
  rescue NameError => e
    errors[:site] << e.message
  end

  def crawler
    klass = Crawlers::LIST[site.to_s.to_sym] || raise(CrawlerNotFound)
    klass.new
  end

  def fetch_list_specs
    if url.present?
      data = crawler.parse_list(url)
      self.page_title = data[:title]
      self.total_count = data[:total_count]
      return true
    elsif url_list.present?
      self.page_title = ''
      self.total_count = url_list.split.size
      return true
    end
    false
  rescue => e
    errors[:url] << "は無効です: #{e.message}"
    false
  end

  def execute_crawling
    running!
    touch :started_at

    if url_list.present?
      urls = url_list.split
      update!(total_count: urls.size)
      urls.each { |url| safe_fetch(url) }
    else
      list_page_url = url
      loop do
        data = crawler.parse_list(list_page_url)
        update!(total_count: data[:total_count])
        data[:detail_page_urls].each { |url| safe_fetch(url) }
        list_page_url = data[:next_page_url]
        break if list_page_url.blank?
      end
    end

    completed!
    touch :completed_at
  rescue Cancel
  rescue => e
    failed!
    update!(error_message: e.message)
  end

  def export_csv
    temp = Tempfile.create
    temp << CSV.generate("\xEF\xBB\xBF") do |rows|
      header = false
      web_pages.with_attached_html.find_each(batch_size: 100) do |web_page|
        result = { url: web_page.url }
        begin
          result.merge! crawler.parse_detail(web_page.html.download)
          unless header
            rows << result.keys
            header = true
          end

          rows << result.values.map { |v| v.to_s }
        rescue => e
          Rails.logger.error e
        end
      end
    end

    temp.rewind
    temp
  end

  def safe_fetch(url)
    raise Cancel if reload.canceled? # statusがcanceledなら停止
    web_page = web_pages.find_or_create_by!(url: url.to_s)
    return if web_page.fetched?

    fetch_options = {}
    if crawler.user_agent.present?
      fetch_options['User-Agent'] = crawler.user_agent
    end

    web_page.fetch_contents(fetch_options)
    sleep WAIT_TIME
  end
end
