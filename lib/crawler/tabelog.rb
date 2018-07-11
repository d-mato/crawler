require 'open-uri'

class Crawler::Tabelog
  def parse_list(url)
    html = open(url)
    Rails.logger.info "tabelog crawler got #{url}"
    doc = Nokogiri.parse(html)
    {
      title: doc.title,
      total_count: doc.at('.list-condition__count').text.to_i,
      current_page: doc.at('.c-pagination__num.is-current').text.to_i,
      detail_page_urls: doc.css('.list-rst__rst-name a').map { |a| a[:href] },
      next_page_url: doc.at('.c-pagination__item:last a').try!(:[], :href)
    }
  end
end
