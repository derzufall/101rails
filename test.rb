require 'watir-webdriver'
require "watir-webdriver/wait"
require 'cgi'
require 'timeout'

@b = Watir::Browser.new :firefox
@b.window.resize_to(800, 800)
@b.window.move_to(0, 0)

def create_screenshot(page)

  start = Time.now

  begin
    Timeout.timeout(15) do
      @b.goto "http://101companies.org/wiki/#{page}"
      @b.div(:class, 'triple').wait_until_present
      @b.div(:id, 'backlinks').wait_until_present
      @b.div(:class, 'content-loading').wait_while_present
    end
  rescue
    puts "Wait too long for #{page}"
  end

  puts "Spent #{Time.now - start} seconds for page #{page}"
  sleep 1
  @b.screenshot.save CGI::escape(page)+"--#{Time.now}.png"

end

# warm up domain resolving
@b.goto "http://101companies.org/"

1.times do
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
