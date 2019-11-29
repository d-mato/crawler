class Crawlers::JGroup
  include Crawlers::Common

  def parse_list(url)
    doc = Nokogiri.parse(open(url).read)
    base_uri = URI('https://www.jgroup.jp')
    next_page_url = doc.at('.pagination_next > a').try!(:[], :href)
    {
      title: doc.title,
      total_count: doc.at('#result_tit dl > dt > span').text.to_i,
      detail_page_urls: doc.css('.result_list > a').map { |a| base_uri + a[:href] },
      next_page_url: next_page_url ? base_uri + next_page_url : nil,
    }
  end

  def parse_detail(html)
    doc = Nokogiri.parse(html)

    data = {
      name: doc.at('.breadcrumb li:last').text.strip,
      area: doc.at('#detail_tit01 p:first')&.text&.strip,
      genre: doc.at('#detail_tit01 p:last')&.text&.strip,
    }

    column_names = %w[住所 電話番号 予算 最大宴会人数 貸切 個室 株主優待券	ランチ	カップルシート]
    column_names.each do |name|
      data[name] = nil
    end

    doc.css('#table01 th, #table02 th').each do |th|
      column_name = th.text.to_s.strip
      if column_name.in? column_names
        data[column_name] = th.next_element.text.strip
      end
    end

    data
  end
end
