class Crawler::Ramendb
  include Crawler::Common

  def parse_list(html_or_url)
    doc = Nokogiri.parse(detect_html(html_or_url))
    base_uri = URI('https://ramendb.supleks.jp')
    if next_link = doc.at('.pages > a.next')
      next_page_url = (base_uri + next_link[:onclick].match(/href='(.+?)'/)[1]).to_s
    end

    {
      title: doc.title,
      total_count: 0, # 全件数は取れない
      detail_page_urls: doc.css('#searched > li > a').map { |a| (base_uri + a[:href]).to_s },
      next_page_url: next_page_url,
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
      reviewCount: json.dig('aggregateRating', 'reviewCount'),
      links: doc.css('#links > a').map { |a| a[:href] }.join("\n"),
    }
  end
end
