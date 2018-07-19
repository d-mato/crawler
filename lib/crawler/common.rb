require 'open-uri'
require 'nokogiri'

module Crawler::Common
  def detect_html(html_or_url)
    html_or_url.match?(/\A#{URI.regexp(%w[http https])}\z/) ? open(html_or_url).read : html_or_url
  end
end
