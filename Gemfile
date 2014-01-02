require 'rbconfig'
require 'pp'
is_windows = !!(RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)
puts RbConfig::CONFIG['host_os']

# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
source 'http://rubygems.org'

if is_windows
  gem 'win32console'
end

gem 'wdm', '>= 0.1.0' if is_windows
gem 'thin'

gem 'actionpack', '~> 3.2'
gem 'railties', '~> 3.2'
gem 'tzinfo'
gem 'jquery-rails'
gem 'jasmine'
gem 'slim'

# Thought this might be required for guard but doesn't seem to work anyways.
# gem 'rb-readline'

gem 'guard'
# gem "jasminerice", :git => 'https://github.com/bradphelan/jasminerice.git'
# gem 'jasminerice'
# gem 'jquery-rails'

gem 'guard-jasmine'
gem 'jasminerice'
# # gem 'jasmine-headless-webkit'
gem 'guard-coffeescript'
# gem 'guard-copy'
# gem 'guard-jasmine-headless-webkit'
gem 'guard-shell'
gem 'snapimage', '0.2.1'
gem 'rb-inotify' #, '~> 0.8.8'


# source 'https://rubygems.org'

# group :assets do
#   gem 'coffee-script'
# end

# group :development, :test do
#   gem 'actionpack', '~> 3.2'
#   gem 'railties',   '~> 3.2'
#   gem 'tzinfo'

#   gem 'thin'

#   gem 'slim'

#   gem 'jasminerice'
#   gem 'jquery-rails'
#   gem 'guard-jasmine'
# end
