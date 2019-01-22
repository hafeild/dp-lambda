source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


gem 'rails', '~> 5.0.2'
gem 'bcrypt', git: 'https://github.com/codahale/bcrypt-ruby.git', :require => 'bcrypt'
gem 'figaro',       '1.1.1'
gem 'sqlite3'
gem 'puma', '~> 3.0'
gem 'bootstrap-sass','3.3.7'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'jquery-rails'
# gem 'turbolinks', '~> 5'
#gem 'jbuilder', '~> 2.5'
gem 'rails-controller-testing', '1.0.1'
gem 'bootsy'
gem 'mini_magick'
gem 'sunspot_rails', '2.3.0'
gem 'sunspot_solr', '2.3.0'
gem 'rb-readline'
gem 'highline'
gem "paperclip", "~> 5.0.0"
gem 'rails-html-sanitizer', '~> 1.0.4'
gem 'loofah', '>= 2.2.3'
gem 'rack', '>= 2.0.6'
gem 'jquery-ui-rails', '6.0.1'
gem 'minitest', '5.10.3'
gem "nokogiri", ">= 1.8.5"



gem 'wdm', '>= 0.1.0' if Gem.win_platform?

# ## To help with security issues.
# gem 'sprockets', '~> 3.7.2'
# gem 'ffi', '~> 1.9.24'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :production do
  gem 'pg',      '0.21'
  gem 'unicorn', '5.3.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
