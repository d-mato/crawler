class Crawler::Ramendb
  include Crawler::Common

  def parse_list(url)
    doc = Nokogiri.parse(open(Addressable::URI.parse(url).normalize.to_s).read)
    base_uri = 'https://ramendb.supleks.jp'
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

  def parse_detail(html)
    doc = Nokogiri.parse(html)
    json = JSON.parse(doc.at('script[type="application/ld+json"]').text)
    {
      name: json['name'],
      image: json['image'],
      postalCode: doc.at("[itemprop='address']")&.text.to_s[/〒(\d{3}-\d{4})/,1], # ld+jsonには空文字しか入ってないのでページ内から取る
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
      closed: doc.title.start_with?('【閉店】'),
    }
  end
end
