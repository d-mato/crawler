class Crawler::TokyoTenryu
  include Crawler::Common

  def parse_list(url)
    doc = Nokogiri.parse(open(Addressable::URI.parse(url)).read)
    base_uri = URI('https://tokyo-tenryu-job.jp')
    next_page_path = doc.css('a.pager').find { |a| a.text.strip == '次へ' }.try!(:[], :href)
    {
      title: doc.title,
      total_count: doc.at('.ttl-lv2-large').text.to_i,
      detail_page_urls: doc.css('a.cassette-link').map { |a| base_uri + a[:href] },
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
      postalCode: json.dig('jobLocation', 'address', 'postalCode'),
      employmentType: json.dig('employmentType'),
      title: json.dig('title'),
      workHours: json.dig('workHours'),
      baseSalaryUnit: json.dig('baseSalary', 'value', 'unitText'),
      baseSalaryValue: json.dig('baseSalary', 'value', 'value'),
      datePosted: json.dig('datePosted'),
    }
  end
end
