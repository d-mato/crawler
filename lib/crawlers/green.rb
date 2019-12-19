class Crawlers::Green
  include Crawlers::Common

  def parse_list(url)
    doc = Nokogiri.parse(open(url).read)
    base_uri = URI('https://www.green-japan.com')
    next_page_url = doc.at('a.next_page').try!(:[], :href)
    {
      title: doc.title,
      total_count: 0,  # 企業数はJSで遅延ロードしている
      detail_page_urls: doc.search('.srch-rslt .js-search-result-box').map { |a| base_uri + a[:href] },
      next_page_url: next_page_url ? base_uri + next_page_url : nil,
    }
  end

  def parse_detail(html)
    doc = Nokogiri.parse(html)

    salary_range = nil
    meta_tags = doc.search('.job-offer-meta-tags > li')
    if meta_tags
      meta_tags.each do |meta_tag|
        if meta_tag.at('.icon-salary')
          salary_range = meta_tag.text.strip
        end
      end
    end

    data = {
      name: doc.at('h2').text.strip,
      company: doc.at('.company-info-box h4 > text()')&.text&.strip,
      salary_range: salary_range,
    }

    data
  end
end
