require 'open-uri'
require 'csv'

# ミシュランガイドは詳細ページが見られないので個別に作った
class Scripts::Michelin
  def initialize(endpoint = "https://japanguide.michelin.co.jp/restaurant/")
    @endpoint = endpoint
  end

  def execute
    @list = []
    page = 1
    loop do
      uri = URI(@endpoint)
      uri.query = { p: page }.to_query

      begin
        html = open(uri).read
      rescue OpenURI::HTTPError
        break
      end

      @list += parse(html)

      page += 1
      sleep 2
    end
  end

  def parse(html)
    doc = Nokogiri.parse(html)

    doc.css('.shop-list__item').map do |item|
      {
        name: item.at('.shop-list__name').text.strip,
        genre: item.at('.shop-list__genre').text.strip,
        address: item.at('.shop-list__adress').text.strip,
        tel: item.at('.shop-list__tel').text.strip,
      }
    end
  end

  def to_csv
    @list.map { |shop| shop.values.to_csv }.join
  end
end