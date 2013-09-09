require 'watir-webdriver'
require "watir-webdriver/wait"
require 'cgi'
require 'timeout'
require 'colorize'

@b = Watir::Browser.new :phantomjs

def create_screenshot(page)

  start = Time.now

  begin
    Timeout.timeout(15) do
      @b.goto "http://101companies.org/wiki/#{page}"
      @b.div(:class, 'triple').wait_until_present
      @b.div(:id, 'backlinks').wait_until_present
      @b.div(:class, 'content-loading').wait_while_present
      time_spent = Time.now - start
      out_str = "Spent #{time_spent} seconds for page #{page}"
      puts (time_spent.to_f > 3) ? out_str.yellow : out_str.green
    end
  rescue
    puts "Waited too long for #{page}".red
  end
  sleep 1
  @b.screenshot.save "screenshots/#{CGI::escape(page)}--#{Time.now}.png"

end

# warm up domain resolving
@b.goto "http://101companies.org/"

start = Time.now
puts "Started at #{start}".light_blue
50.times do
  puts '------------------------------------------------'.light_blue
  create_screenshot '@project'
  create_screenshot 'Namespace:Feature'
  create_screenshot 'Monad'
  # pic
  create_screenshot 'Contribution:pyDWH'
  # slideshare
  create_screenshot 'Script:Functional_OO_programming'
  # youtube
  create_screenshot 'Quicksort'
end

@b.close

puts "Ended at #{Time.now - start}".light_blue
