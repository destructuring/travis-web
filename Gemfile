source 'http://rubygems.org'
ruby '1.9.3'

gem 'puma'
gem 'rack-ssl', '~> 1.3'
gem 'rack-protection', '~> 1.3'
gem 'rack-cache'
gem 'rack-mobile-detect'
gem 'sinatra'
gem 'hashr'

group :assets do
  gem 'rake-pipeline',  github: 'livingsocial/rake-pipeline'
  gem 'rake-pipeline-web-filters', github: 'wycats/rake-pipeline-web-filters'
  gem 'rake-pipeline-i18n-filters'
  gem 'coffee-script'
  gem 'compass'
  gem 'tilt'
  gem 'uglifier'
  gem 'yui-compressor'
  gem 'libv8', '~> 3.16.0'
end

group :development, :test do
  gem 'rake'
  gem 'localeapp'
  gem 'localeapp-handlebars_i18n'
end


group :development do
  # gem 'debugger'
  gem 'foreman'
  gem 'rerun'
  gem 'guard'
  gem 'rb-fsevent', '~> 0.9.1'
end

group :test do
  gem 'rspec', '~> 2.11'
  gem 'sinatra-contrib'
end

