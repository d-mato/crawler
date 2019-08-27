class Crawler::IkyuRestaurant
  include Crawler::Common

  def parse_list(url)
    doc = Nokogiri.parse(open(Addressable::URI.parse(url).normalize.to_s).read)
    base_uri = URI('https://restaurant.ikyu.com')
    next_page_path = doc.at('.des_currentPage + a')&.try!(:[], :href)
    {
      title: doc.title,
      total_count: doc.at('#editHeadingView > span').text.slice(/全(\d+)件/, 1).to_i,
      detail_page_urls: doc.css('.tagPlan_resContent > a').map { |a| base_uri + a[:href] },
      next_page_url: next_page_path ? base_uri + next_page_path : nil
    }
  end

  def parse_detail(html)
    doc = Nokogiri.parse(html)
    json = JSON.parse(doc.at('script[type="application/ld+json"]').text)
    {
      name: json['name'],
      postalCode: json.dig('address', 'postalCode'),
      addressRegion: json.dig('address', 'addressRegion'),
      addressLocality: json.dig('address', 'addressLocality'),
      streetAddress: json.dig('address', 'streetAddress'),
      telephone: json['telephone'],
      priceRange: json['priceRange'],
      servesCuisine: json['servesCuisine'],
    }
  end
end
