#!/usr/bin/ruby

require 'mechanize'
require 'logger'

class Crawler

  def initialize(logger:, retry_count:5)
    @logger = logger
    @retry_count = retry_count
  end

  def crawl(name)
    @agent = Mechanize.new
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
    search_result = page.form_with(:name => 'f') {|search|
      search.q = name
    }.submit
    images = search_result.images.select {|image|
      image.node['name'] = 'imgthumb11'
    }
    return if images.size == 0
    images[0].fetch.save!("img/#{name}.jpg")
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

