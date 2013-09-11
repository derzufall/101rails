require 'watir-webdriver'
require 'cgi'
require 'timeout'
require 'colorize'

@b = Watir::Browser.new :phantomjs

def create_screenshot(page)
  start = Time.now
  screenshot_file_name = 'screenshots/'
  begin
    # wait for 15 seconds and then create an exception
    Timeout.timeout(15) do
      @b.goto "#{@site}wiki/#{page}"
      @b.div(:class, 'triple').wait_until_present
      @b.div(:id, 'backlinks').wait_until_present
      @b.div(:class, 'content-loading').wait_while_present
      time_spent = Time.now - start
      out_str = "Spent #{time_spent} seconds for page #{page}"
      puts (time_spent.to_f > 3) ? out_str.yellow : out_str.green
    end
    screenshot_file_name = screenshot_file_name + 'Success-'
  rescue
    puts "Waited too long for #{page}".red
    screenshot_file_name = screenshot_file_name + 'Failed-'
  end
  @b.screenshot.save "#{screenshot_file_name}#{CGI::escape(page)}--#{Time.now}.png"
end

@site = "http://101companies.org/"
# warm up domain resolving
@b.goto @site

start = Time.now
puts "Started at #{start}".light_blue
# repeat few times to be more precise
1.times do
  puts '------------------------------------------------'.light_blue
  create_screenshot '@project'
  create_screenshot 'Namespace:Feature'
  create_screenshot 'Monad'
  # picture
  create_screenshot 'Contribution:pyDWH'
  # slideshare
  create_screenshot 'Script:Functional_OO_programming'
  # youtube
  create_screenshot 'Quicksort'
end

puts "Ended at #{Time.now - start}".light_blue
@b.close
