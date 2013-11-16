# DO NOT REMOVE THIS LINE!
source 'https://rubygems.org'

# force using encoding
if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

# DO NOT ENTER GEMS WITHOUT GEM NUMBER!
# OR I WILL CUT YOUR FINGER!

# TODO: update to rails 4.0.0
# need to be updated:
# * aced_rails
# * mongoid
# * rails-backbone
gem 'rails', '3.2.13'

# send email on error
gem 'exception_notification', '4.0.1'

# twitter bootstrap as sass
gem 'bootstrap-sass', '2.3.2.2'

group :assets do
  gem 'sass-rails', '3.2.6'
  gem 'coffee-rails', '3.2.2'
  gem 'uglifier', '2.2.1'
  gem 'compass-rails', '1.0.3'
end

# frontend
gem 'jquery-rails', '2.1.3'
gem 'jquery-ui-rails', '3.0.1'
gem 'rails-backbone', '0.9.10'
gem 'haml-rails', '0.4'

# database
# TODO: before upgrade to 4.0 include mongoid-paranoia
gem 'mongoid', '3.1.5'

# search eninge
gem 'mongoid_search', '0.3.2'

# security
gem 'bcrypt-ruby', '3.1.2'

# github auth
gem 'omniauth', '1.1.4'
gem 'omniauth-github', '1.1.1'

# github integration
gem 'octokit', '2.6.0'

# font with bundled icons
gem 'font-awesome-rails', '3.2.1.3'

# roles and permissions
gem 'cancan', '1.6.10'

group :development do
  # remove assets-logs in console
  gem 'quiet_assets', '1.0.2'
  # nice error output
  gem 'better_errors', '1.0.1'
  gem 'binding_of_caller', '0.7.2'
  # web server
  gem 'thin', '1.6.1'
  # colorful console
  gem 'wirble', '0.1.3'

end

# admin interface
gem 'rails_admin', '0.4.9'

# web-scraping
gem 'json_pure', '1.8.1'
gem 'json', '1.8.1'
gem 'httparty', '0.12.0'

# work with mediawiki
gem 'mediawiki-gateway', '0.5.2'
# work with wiki markdown
gem 'wikicloth', :github => 'avaranovich/wikicloth'

gem 'rdf', :github => 'ruby-rdf/rdf'

# source text highlighting
gem 'pygments.rb', '0.5.2'
gem 'closure-compiler', '1.1.10'

gem 'simple_form', '2.1.0'
gem 'select2-rails'

# growl-like notifications
# TODO: replace with solid gem
gem 'gritter', :github => 'burgua/gritter', :branch => 'vendor_dir'

# deploy tool
# TODO: update after reading manual
gem 'capistrano', '2.15.5'

# for wiki-editor
gem 'aced_rails', '0.2.1', :github => 'tschmorleiz/aced_rails'

# for html snapshots
gem 'watir-webdriver', '0.6.4'

gem 'bootstrap-tour-rails', '0.4.0'

gem 'eventmachine', '1.0.3'
gem 'em-http-request', '1.1.1'
