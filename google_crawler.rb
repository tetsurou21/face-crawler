#!/usr/bin/ruby

require 'mechanize'
require 'logger'
require 'open-uri'
require 'fileutils'
require 'json'

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
        #sleep(1)
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
    page = @agent.get('http://www.google.co.jp/imghp')
    search_result = page.form_with(:name => 'f') {|search|
      search.q = name
    }.submit
    # img_links = search_result.links_with(:href => /imgres/)
    rg_metas = search_result.css('.rg_meta')
    if rg_metas.size == 0
      @logger.warn "failed to find image links"
      return
    end
    rg_metas.take(10).each_with_index do |rg_meta, i|
      begin
        json = JSON.parse(rg_meta.text)
        _save(name, json['ou'], i)
        sleep(0.5)
      rescue => e
        @logger.warn(e)
      end
    end
  end

  def _save(name, url, n)
    @logger.info("downloading #{url}")
    open("img/tmp.jpg", 'wb') {|out|
      open(url) {|input|
        out.write(input.read)
      }
    }
    # if not _check("img/tmp.jpg")
    #   @logger.info("face not detected at #{name}##{n}")
    #   return
    # end
    FileUtils.mv("img/tmp.jpg", "img/#{name}_#{n}.jpg")
  end

  def _check(file)
    res = `./facecheck #{file}`.chomp
    res == "true"
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

