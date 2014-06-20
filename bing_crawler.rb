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
        sleep(1 + 1 * n)
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
    filter = URI.encode('filterui:imagesize-large filterui:face-face filterui:photo-photo')
    page = @agent.get("http://www.bing.com/images/search?qft=#{filter}&q=#{name}")
    page.search('.dg_u a').take(10).each_with_index { |a, i|
      json = CGI.unescapeHTML(a['m'])
      if  json =~ /imgurl:"([^"]+)"/
        imgurl = $1
      else
        @logger.warn("can't find imgurl in #{json}")
      end
      @logger.info("saving imgurl #{imgurl}")
      _save(imgurl, "img/#{name}_#{i}.jpg")
    }
  end

  def _save(imgurl, name)
    open(name, 'wb') {|out|
      begin
        open(imgurl) {|input|
          out.write(input.read)
        }
      rescue => e
        @logger.warn(e)
      end
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

