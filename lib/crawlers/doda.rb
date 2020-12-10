class Crawlers::Doda
  include Crawlers::Common

  def parse_list(url)
    # UAを偽装しないとページが返ってこない
    doc = Nokogiri.parse(URI.open(Addressable::URI.parse(url), 'User-Agent' => user_agent).read)
    {
      title: doc.title,
      total_count: doc.at('.counter > .number').text.remove(/\D/).to_i,
      detail_page_urls: doc.css('.layout.layoutList02 .title > a._JobListToDetail').map { |a|
        # 求人詳細とPickUpページが混ざっているので、求人詳細へのリンクに統一する
        # p a[:href].class
        a[:href].gsub(/(j_jid__\d+)(.+)/, '\1') + '/-tab__jd/'
      }, 
      next_page_url: doc.at('.pagenation > li:last').at('a').try!(:[], :href)
    }
  end

  def parse_detail(html)
    doc = Nokogiri.parse(html)
    if doc.at('#job_description_table')
      description_table = doc.at('#job_description_table')
      {
        title: doc.at('//h1/text()')&.text.to_s.strip,
        job_title: find_row(description_table, '仕事内容').at('.explain').text.strip,
        job_detail: find_row(description_table, '仕事内容').at('dl.band_title.space').text.strip,
        target_title: find_row(description_table, '対象となる方').at('.explain').text.strip,
        target_detail: find_row(description_table, '対象となる方').at('.space_large').text.strip,
        employment_type: find_row(description_table, '雇用形態').at('.text_bold.space').text.strip,
      }
    elsif doc.at('.tblDetail01.tblThDetail')
      description_table = doc.at('.tblDetail01.tblThDetail')
      {
        title: doc.at('//h1/text()')&.text.to_s.strip,
        job_title: find_row(description_table, '仕事内容').css('p')[0].text.strip,
        job_detail: find_row(description_table, '仕事内容').css('p')[1].text.strip,
        target_title: find_row(description_table, '対象となる方').css('p')[0].text.strip,
        target_detail: find_row(description_table, '対象となる方').css('p')[1].text.strip,
        employment_type: find_row(description_table, '雇用形態').css('p')[0].text.strip,
      }
    else
      {
        title: doc.at('//h1/text()')&.text.to_s.strip,
        job_title: '',
        job_detail: '',
        target_title: '',
        target_detail: '',
        employment_type: '',
      }
    end
  end

  def user_agent
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100'
  end

  private

  def find_row(table, row_title)
    table.css('tr').find { |tr| tr.at('th')&.text.to_s.strip == row_title }
  end
end
