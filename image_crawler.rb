#!/usr/bin/ruby

require 'mechanize'
require 'logger'
require 'open-uri'

class Crawler

  def initialize(logger:, retry_count:5)
    @logger = logger
    @retry_count = retry_count
  end

  def crawl(name)
    @agent = Mechanize.new {|agent|
      agent.user_agent_alias = 'Mac Safari'
    }
    @retry_count.times {|n|
      begin
        sleep(0.5 + 1 * n)
        @logger.info "crawling #{name}##{n}"
        _crawl(name)
      rescue => e
        @logger.warn(e)
      else
        return
      end
    }
  end

  def _crawl(name)
    page = @agent.get('http://www.google.co.jp')
    search_result = page.form_with(:name => 'gbqf') {|search|
      search.q = name
    }.submit
    img_links = search_result.links_with(:href => /imgres/)
    if img_links.size == 0
      @logger.warn "failed to find image links"
      return
    end
    img_page = img_links[0].click
    if img_page.title !~ /(http.+)/
      @logger.warn "failed to find image"
      return
    end
    url = $1
    @logger.info("downloading #{url}")
    open("img/#{name}.jpg", 'wb') {|out|
      open(url) {|input|
        out.write(input.read)
      }
    }
  end
end

logger = Logger.new(STDERR)
logger.level = Logger::INFO

crawler = Crawler.new logger:logger
# crawler.crawl '佐村河内守'

while line = ARGF.gets
  line.chomp!
  logger.info "crawling #{line}"
  crawler.crawl(line)
end

