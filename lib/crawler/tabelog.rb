require 'open-uri'
require 'nokogiri'

class Crawler::Tabelog
  def parse_list(url)
    html = open(url)
    doc = Nokogiri.parse(html)
    {
      title: doc.title,
      total_count: doc.at('.list-condition__count').text.to_i,
      current_page: doc.at('.c-pagination__num.is-current').text.to_i,
      detail_page_urls: doc.css('.list-rst__rst-name a').map { |a| a[:href] },
      next_page_url: doc.at('.c-pagination__item:last a').try!(:[], :href)
    }
  end

  def parse_detail(body)
    doc = Nokogiri.parse(body)
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
      ratingValue: json.dig('aggregateRating', 'ratingValue')
    }
  end
end
