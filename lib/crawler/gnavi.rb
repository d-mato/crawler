class Crawler::Gnavi
  include Crawler::Common

  def parse_list(url)
    doc = Nokogiri.parse(open(Addressable::URI.parse(url).normalize.to_s).read)
    {
      title: doc.title,
      total_count: doc.at('.result-stats__total').text.remove(/\D/).to_i,
      detail_page_urls: doc.css('.result-cassette__box-headline > a:first-child').map { |a| a[:href] },
      next_page_url: doc.at('a.pagination__arrow-item-inner-next').try!(:[], :href)
    }
  end

  def parse_detail(html)
    doc = Nokogiri.parse(html)
    json = JSON.parse(doc.at('script[type="application/ld+json"]').text)
    json = json.first if json.is_a? Array
    {
      name: json['name'],
      image: json['image'],
      postalCode: json.dig('address', 'postalCode'),
      addressRegion: json.dig('address', 'addressRegion'),
      addressLocality: json.dig('address', 'addressLocality'),
      streetAddress: json.dig('address', 'streetAddress'),
      telephone: json['telephone'],
      priceRange: doc.at('.pricerange')&.text&.strip,
      servesCuisine: json['servesCuisine'],
      seatCount: doc.css('th').find { |el| el.text.strip == '総席数' }&.next_element&.text&.slice(/(\d+)席/, 1),
      regularHoliday: doc.at('tr#info-holiday td')&.text&.strip,
    }
  end
end
