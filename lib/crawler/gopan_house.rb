class Crawler::GopanHouse
  include Crawler::Common

  def parse_list(url)
    doc = Nokogiri.parse(open(Addressable::URI.parse(url)).read)
    base_uri = URI('https://okunicorp-partner.net')
    next_page_path = doc.css('.paging-top a').find { |a| a.text.strip.match?(/次へ/) }.try!(:[], :href)
    {
      title: doc.title,
      total_count: doc.at('.pagehead strong').text.to_i,
      detail_page_urls: doc.css('.listbox .heading a').map { |a| base_uri + a[:href] },
      next_page_url: next_page_path ? base_uri + next_page_path : nil
    }
  end

  def parse_detail(html)
    doc = Nokogiri.parse(html)
    json = JSON.parse(doc.at('script[type="application/ld+json"]').text)
    {
      name: json.dig('identifier', 'name'),
      organizationName: json.dig('hiringOrganization', 'name'),
      addressRegion: json.dig('jobLocation', 'address', 'addressRegion'),
      addressLocality: json.dig('jobLocation', 'address', 'addressLocality'),
      streetAddress: json.dig('jobLocation', 'address', 'streetAddress'),
      title: json.dig('title'),
      baseSalaryUnit: json.dig('baseSalary', 'value', 'unitText'),
      datePosted: json.dig('datePosted'),
    }
  end
end
