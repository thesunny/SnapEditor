# # Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# # For licensing, see LICENSE.
# # require "rubygems"
# # require "bundler/setup"
# require "jasminerice"
# require "json"
# require "snapimage"

# base_dir = File.dirname(File.expand_path(__FILE__))
# # Don't cache. This is helpful because IE tends to cache all asynchronously
# # loaded files. Since RequireJS is all about asynchronously loading files, the
# # tests will load old files. This forces IE to always grab the latest files.
# no_cache = {
#   "Cache-Control" => "no-cache, no-store, max-age=0, must-revalidate",
#   "Pragma" => "no-cache",
#   "Expires" => "Fri, 29 Aug 1997 02:14:00 EST"
# }
# app = Proc.new do |env|
#   request = Rack::Request.new(env)
#   request.path_info = request.path_info.sub(base_dir, "")
#   request.path_info = "/runner.html" if /^\/+$/.match(request.path_info)
#   response = Rack::File.new(".").call(request.env)
#   response[1].merge!(no_cache)
#   response
# end

# use SnapImage::Middleware
# #use SnapImage::Middleware, config: "snapimage_secure.yml", path: "/snapimage_api_secure"
# run app


# bundle exec rackup -p 3000

require 'action_controller/railtie'
require 'jasminerice'
require 'guard/jasmine'
require 'sprockets/railtie'
# require 'jquery-rails'
require 'slim'

class JasmineTest < Rails::Application
  routes.append do
    mount Jasminerice::Engine, at: '/jasmine'
  end

  # config.cache_classes = true
  config.active_support.deprecation = :log
  config.assets.enabled = true
  config.assets.version = '1.0'
  config.secret_token = '9696be98e32a5f213730cb7ed6161c79'
  config.assets.paths << Rails.root.join("output")
  config.assets.paths << Rails.root.join("coffeescripts")
  config.assets.paths << Rails.root.join("build")
  config.assets.paths << Rails.root.join("spec", "javascripts", "support", "assets")
  config.assets.paths << Rails.root.join("lib")
  # config.assets.paths << Rails.root.join("lib", "JavaScript-Canvas-toBlob")
  # config.assets.paths << Rails.root.join("lib", "JavaScript-Load-Image")
  # config.assets.paths << Rails.root.join("lib", "jQuery-File-Upload")
  # config.assets.paths << Rails.root.join("lib", "JavaScript-Canvas-toBlob")
  # config.assets.paths << Rails.root.join("spec","acceptance")

end

JasmineTest.initialize!
run JasmineTest