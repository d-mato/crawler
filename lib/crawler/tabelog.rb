require 'open-uri'

class Crawler::Tabelog
  def parse_list(url)
    html = open(url)
    Rails.logger.info "tabelog crawler got #{url}"
    doc = Nokogiri.parse(html)
    {
      title: doc.title,
      total_count: doc.at('.list-condition__count').text.to_i,
    }
  end
end