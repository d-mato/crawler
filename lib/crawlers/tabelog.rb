class Crawlers::Tabelog
  include Crawlers::Common

  def parse_list(url)
    doc = Nokogiri.parse(open(Addressable::URI.parse(url).normalize.to_s).read)
    {
      title: doc.title,
      total_count: doc.at('.c-page-count__num:last-child').text.to_i,
      detail_page_urls: doc.css('.list-rst__rst-name a.list-rst__rst-name-target').map { |a| a[:href] },
      next_page_url: doc.at('.c-pagination__item:last a').try!(:[], :href)
    }
  end

  def parse_detail(html)
    doc = Nokogiri.parse(html)
    json = JSON.parse(doc.at('script[type="application/ld+json"]').text)
    restaurant = json[0]
    {
      name: restaurant['name'],
      image: restaurant['image'],
      postalCode: restaurant.dig('address', 'postalCode'),
      addressRegion: restaurant.dig('address', 'addressRegion'),
      addressLocality: restaurant.dig('address', 'addressLocality'),
      streetAddress: restaurant.dig('address', 'streetAddress'),
      telephone: restaurant['telephone'],
      priceRange: restaurant['priceRange'],
      servesCuisine: restaurant['servesCuisine'],
      ratingCount: restaurant.dig('aggregateRating', 'ratingCount'),
      ratingValue: restaurant.dig('aggregateRating', 'ratingValue'),
      seatCount: doc.at('//th[.="席数"]/following-sibling::td')&.text&.slice(/(\d+)席/, 1),
      regularHoliday: doc.at('#short-comment')&.text&.strip,
      openingHours: doc.at('//th[.="営業時間・定休日"]/following-sibling::td')&.text&.strip,
      openingDay: doc.at('.rstinfo-opened-date')&.text&.strip,
      lunchTimeOpened: doc.at('//i[.="昼の予算"]').present?
    }
  end
end
