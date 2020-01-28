class Crawlers::InshokutenCom
  include Crawlers::Common

  def parse_list(url)
    doc = Nokogiri.parse(open(Addressable::URI.parse(url)).read)
    base_uri = URI('https://job.inshokuten.com')
    next_page_path = doc.at('a.next-link').try!(:[], :href)
    {
      title: doc.title,
      total_count: doc.at('.search-shop-number').text.to_i,
      detail_page_urls: doc.css('article.shop-box:not(.js-adShop) .catch-phrase > a').map { |a| URI(a[:href]) },
      next_page_url: next_page_path ? base_uri + next_page_path : nil
    }
  end

  def parse_detail(html)
    doc = Nokogiri.parse(html)
    json = JSON.parse(doc.at('script[type="application/ld+json"]').text)
    {
      title: json['title'],
      organization: json.dig('hiringOrganization', 'name'),
      postalCode: json.dig('jobLocation', 'address', 'postalCode'),
      addressRegion: json.dig('jobLocation', 'address', 'addressRegion'),
      addressLocality: json.dig('jobLocation', 'address', 'addressLocality'),
      streetAddress: json.dig('jobLocation', 'address', 'streetAddress'),
    }
  end
end
