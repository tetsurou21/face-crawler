#!/usr/bin/ruby

require 'mechanize'
require 'logger'
require 'open-uri'

class Counter

  def initialize(logger:, retry_count:5)
    @logger = logger
    @retry_count = retry_count
  end

  def count(name)
    @agent = Mechanize.new {|agent|
      agent.user_agent_alias = 'Mac Safari'
      cookie = Mechanize::Cookie.new(
        'GOOGLE_ABUSE_EXEMPTION', 
        'ID=f8efe0679bd47021:TM=1402210271:C=c:IP=220.215.173.42-:S=APGng0tMKs9vGxbRWUpxjVr5IzbDTSmufA', 
        :path => '/',
        :domain => '.google.co.jp'
      )
      agent.cookie_jar.add(cookie)
    }
    @retry_count.times {|n|
      begin
        sleep(1.5 + 1 * n)
        @logger.info "counting #{name}##{n}"
        _count(name)
      rescue => e
        @logger.warn(e)
      else
        return
      end
    }
  end

  def _count(name)
    page = @agent.get('http://www.google.co.jp')
    search_result = page.form_with(:name => 'gbqf') {|search|
      search.q = "\"#{name}\""
    }.submit
    stat = search_result.search('#resultStats').text
    if stat =~ /([0-9,]+) 件/
      c = $1.gsub(',','')
      puts "#{name}\t#{c}"
    else
      @logger.warn("Can't find result counts: #{name}")
    end
  end
end

logger = Logger.new(STDERR)
logger.level = Logger::INFO

counter = Counter.new logger:logger

while line = ARGF.gets
  line.chomp!
  logger.info "counting #{line}"
  counter.count(line)
end

