#!/usr/bin/ruby

require 'mechanize'
require 'logger'

first_urls = [
  'http://ja.wikipedia.org/wiki/Category:%E6%97%A5%E6%9C%AC%E3%81%AE%E6%AD%8C%E6%89%8B', # 歌手
  'http://ja.wikipedia.org/wiki/Category:%E3%81%8A%E7%AC%91%E3%81%84%E8%8A%B8%E4%BA%BA', # お笑い芸人
  'http://ja.wikipedia.org/wiki/Category:%E6%97%A5%E6%9C%AC%E3%81%AE%E4%BF%B3%E5%84%AA', # 俳優
]

class Crawler
  def initialize(logger:)
    @agent = Mechanize.new
    @logger = logger
  end

  def crawl_all_names(url)
    while true
      @logger.info("crawling url #{url}")

      page = @agent.get(url)

      links = page.search('#mw-pages li a')
      links.each {|li|
        puts li.text.gsub(/[（(].+[）)]/,'').gsub(/ */, '')
      }

      links = page.search('#mw-pages > a').select {|link|
        link.text =~ /次の/
      }
      urls = links.map {|link|
        link['href']
      }

      break if urls.size == 0
      url = urls[0]
    end
  end
end

logger = Logger.new(STDERR)
logger.level = Logger::INFO

crawler = Crawler.new logger:logger

first_urls.each {|url|
  crawler.crawl_all_names(url)
}
