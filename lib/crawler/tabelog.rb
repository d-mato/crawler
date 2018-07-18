require 'open-uri'
require 'nokogiri'

class Crawler::Tabelog
  def parse_list(html_or_url)
    doc = Nokogiri.parse(detect_html(html_or_url))
    {
      title: doc.title,
      total_count: doc.at('.list-condition__count').text.to_i,
      detail_page_urls: doc.css('.list-rst__rst-name a.list-rst__rst-name-target').map { |a| a[:href] },
      next_page_url: doc.at('.c-pagination__item:last a').try!(:[], :href)
    }
  end

  def parse_detail(html_or_url)
    doc = Nokogiri.parse(detect_html(html_or_url))
    json = JSON.parse(doc.at('script[type="application/ld+json"]').text)
    {
      name: json['name'],
      image: json['image'],
      postalCode: json.dig('address', 'postalCode'),
      addressRegion: json.dig('address', 'addressRegion'),
      addressLocality: json.dig('address', 'addressLocality'),
      streetAddress: json.dig('address', 'streetAddress'),
      telephone: json['telephone'],
      priceRange: json['priceRange'],
      servesCuisine: json['servesCuisine'],
      ratingCount: json.dig('aggregateRating', 'ratingCount'),
      ratingValue: json.dig('aggregateRating', 'ratingValue'),
      seatCount: doc.css('th').find { |el| el.text.strip == '席数' }&.next_element&.text&.slice(/(\d+)席/, 1),
      regularHoliday: doc.at('#short-comment')&.text.strip,
    }
  end

  private

  def detect_html(html_or_url)
    html_or_url.match?(/\A#{URI::regexp(%w(http https))}\z/) ? open(html_or_url).read : html_or_url
  end
end
