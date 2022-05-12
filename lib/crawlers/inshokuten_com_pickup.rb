class Crawlers::InshokutenComPickup
  include Crawlers::Common

  def parse_list(url)
    doc = Nokogiri.parse(open(Addressable::URI.parse(url)).read)
    base_uri = URI('https://job.inshokuten.com')
    next_page_path = doc.at('.paging a[rel="next"]').try!(:[], :href)
    {
      title: doc.title.to_s.strip,
      total_count: doc.at('.number.search-shop-number').text.to_i,
      detail_page_urls: doc.css('.pickupCompanyBox__companyName > a').map { |a| base_uri + a[:href] },
      next_page_url: next_page_path ? base_uri + next_page_path : nil
    }
  end

  def parse_detail(html)
    doc = Nokogiri.parse(html)
    data = {}
    %w[社名 代表者 設立 本社 HP 事業内容 店舗数 勤務地 業態].each do |key|
      tr = doc.css('.companyInfo__table tr, .companyInfo__table tr').find { |tr| tr.at('th').text.strip == key }
      if tr
        td = tr.at('td')
        data[key] =
          case key
          when 'HP'
            td.at('a').try!(:[], :href)
          else
            td.text.strip
          end
      else
        data[key] = ''
      end
    end
    data
  end
end
