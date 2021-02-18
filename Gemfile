source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


gem 'bcrypt',  '3.1.15'
gem 'bootstrap-sass', '3.4.1'
gem 'bootsy'
gem 'coffee-rails', '5.0'
gem 'figaro',  '1.2'
gem 'highline'
gem 'jquery-rails', '4.4'
gem 'jquery-ui-rails', '6.0'
gem 'loofah', '2.9'
gem 'mini_magick', '4.11'
gem 'minitest', '5.14'
gem 'nokogiri', '1.11'
gem 'paperclip', '6.1'
gem 'rails',   '6.1'
gem 'rails-controller-testing', '1.0.5'
gem 'rails-html-sanitizer', '1.3'
gem 'rack', '2.2.3'
gem 'rb-readline'
gem 'sass-rails', '6.0'
gem 'sqlite3', '1.4.2'
gem 'sunspot_rails', '2.5'
gem 'sunspot_solr', '2.5'
gem 'uglifier', '4.2'
gem 'web-console', '4.0', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  # gem 'byebug', platform: :mri
  gem 'byebug', '11.1'
end

group :development do
  gem 'listen', '~> 3.0.5'
end

group :production do
  gem 'pg',      '1.2.3'
  gem 'unicorn', '5.6'
end
