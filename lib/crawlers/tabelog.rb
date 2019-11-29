class Crawlers::Tabelog
  include Crawlers::Common

  def parse_list(url)
    doc = Nokogiri.parse(open(Addressable::URI.parse(url).normalize.to_s).read)
    {
      title: doc.title,
      total_count: doc.at('.list-condition__count').text.to_i,
      detail_page_urls: doc.css('.list-rst__rst-name a.list-rst__rst-name-target').map { |a| a[:href] },
      next_page_url: doc.at('.c-pagination__item:last a').try!(:[], :href)
    }
  end

  def parse_detail(html)
    doc = Nokogiri.parse(html)
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
      openingHours: doc.css('th').find { |el| el.text.strip == '営業時間' }&.next_element&.text&.strip,
      openingDay: doc.at('.rstinfo-opened-date')&.text&.strip,
      lunchTimeOpened: doc.css('i').find { |el| el.text.strip == '昼の予算' }.present?
    }
  end
end
