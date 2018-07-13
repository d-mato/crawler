require 'csv'

class CrawlerJob < ApplicationRecord
  WAIT_TIME = 10

  # belongs_to :user
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
  validates :url, presence: true, format: /\A#{URI::regexp(%w(http https))}\z/

  def crawler
    @crawler ||= "crawler/#{site}".classify.constantize.new
  end

  def fetch_list_specs
    data = crawler.parse_list(url)
    self.page_title = data[:title]
    self.total_count = data[:total_count]
    true
  rescue => e
    errors[:url] << "は無効です: #{e.message}"
    false
  end

  def current_count
    web_pages.fetched.count
  end

  def execute_crawling
    running!
    touch :started_at

    list_page_url = url
    loop do
      data = crawler.parse_list(list_page_url)
      data[:detail_page_urls].each do |url|
        web_pages.find_or_create_by!(url: url)
      end
      list_page_url = data[:next_page_url]
      break unless list_page_url
      sleep WAIT_TIME
    end

    update!(total_count: web_pages.count)
    web_pages.each do |web_page|
      return if reload.canceled?
      next if web_page.fetched?

      web_page.fetch_contents
      sleep WAIT_TIME
    end

    completed!
    touch :completed_at
  rescue => e
    failed!
    update!(error_message: e.message)
  end

  def export_csv
    CSV.generate(encoding: Encoding::SJIS, row_sep: "\r\n", force_quotes: true) do |csv|
      header = false
      web_pages.each.with_index do |web_page, index|
        result = { url: web_page.url }
        begin
          result.merge! crawler.parse_detail(web_page.body)
          unless header
            csv << result.keys
            header = true
          end

          csv << result.values
        rescue
        end
      end
    end
  end
end
