class Crawlers::CookbizCompany
  include Crawlers::Common

  def parse_list(url)
    doc = Nokogiri.parse(open(url).read)
    base_uri = URI('https://cookbiz.jp')
    {
      title: doc.title,
      total_count: 0, # 全件数は取れない
      detail_page_urls: doc.css('.list-content > ul > li > a').map { |a| uri = base_uri; uri.path = a[:href]; uri.to_s },
      next_page_url: doc.at('.pagination li.next a').try!(:[], :href),
    }
  end

  def parse_detail(html)
    column_names = %w[企業名 代表者 業種／業態 事業内容 設立 資本金 従業員数 売上高 事業所 URL]
    data = column_names.map { |name| [name, nil] }.to_h

    doc = Nokogiri.parse(html)
    doc.css('.job-company-info-table tr').each do |tr|
      column_name = tr.at('th')&.text.to_s.strip
      if column_name.in? column_names
        data[column_name] = tr.at('td')&.text.to_s.strip.gsub(/[[:blank:]]{2,}/, ' ')
      end
    end

    data
  end
end
