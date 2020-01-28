class Crawlers::Townwork
  include Crawlers::Common

  def parse_list(url)
    doc = Nokogiri.parse(open(Addressable::URI.parse(url)).read)
    base_uri = URI('https://townwork.net')
    next_page_path = doc.at('.pager-next-btn a').try!(:[], :href)
    {
      title: doc.title,
      total_count: doc.at('.hit-num').text.remove(/\D/).to_i,
      detail_page_urls: doc.css('.job-lst-main-cassette-wrap a.job-lst-main-box-inner')
                          .reject { |a| a[:href].include?('https://www.hatalike.jp/') || a[:href].include?('opf=') }
                          .map { |a| base_uri + a[:href] },
      next_page_url: next_page_path ? base_uri + next_page_path : nil
    }
  end

  def parse_detail(html)
    doc = Nokogiri.parse(html)
    {
      title: doc.at('.jsc-company-txt').text.strip,
      company: doc.xpath('//dl[contains(dt, "社名（店舗名）")]/dd')[0]&.text&.strip,
      address: doc.xpath('//dl[contains(dt, "会社住所")]/dd')[0]&.text.to_s.strip,
    }
  end
end
