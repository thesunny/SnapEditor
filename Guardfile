# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
# More info at https://github.com/guard/guard#readme
spec_location = "spec/javascripts/%s.spec"

# uncomment if you use NerdCapsSpec.js
# spec_location = "spec/javascripts/%sSpec"

all_on_start = false

guard :coffeescript, input: "coffeescripts", output: "javascripts", bare: true, shallow: false, all_on_start: all_on_start
# guard :coffeescript, input: "spec-coffeescripts", output: "spec", bare: true, shallow: false, all_on_start: all_on_start

# # Compiles all the spec-coffeescripts files into the spec directory except for
# # the .coffee script files themselves. This is so that we can work exclusively
# # in the spec-coffeescripts directory to write our specs.
# guard :shell, all_on_start: all_on_start do
#   watch(%r{^spec-coffeescripts/(.*)}) do |m|
#     path = m[0]
#     subpath = m[1]
#     # puts m[0]
#     # n m[0]
#     # n m[0]
#     if !File.directory?(path) && File.extname(path) != '.coffee'
#       # puts m[1]
#       # puts path + " Copy it"
#       # pp path, File.join("spec", subpath)

#       dest = File.join("spec", subpath)
#       dest_dir = File.dirname(dest)
#       FileUtils.mkdir_p(dest_dir)
#       FileUtils.cp path, dest
#       "Copied #{path} to spec"

#       # FileUtils.cp_r path, File.join()
#     else
#       nil
#     end
#     # dir = File.directory?(path)
#     # if !dir
#     #   FileUtils.copy
#     # end
#     # path + " has changed"
#   end
# end

guard :shell, all_on_start: all_on_start do
  watch(%r{^coffeescripts/.*[.]coffee}) do |m|
    output = `bundle exec rake build_for_guard`
    if $?.to_i == 0
      n "Successfully built build/snapeditor.js", "Build Successful", :success
    else
      n "Please check console for errors", "Build Failed", :failed
    end
    # output
  end
end

# IMPORTANT!
# Suprer Important note! Currently we have to modify guard jasmine to get the
# tests to run. It is expecting specs to look like _spec.js but we use the
# format .spec.js. This is because Wes originally ran guard-jasmine-headless-webkit
# which worked fine with that file naming format.
#
# Kind of sucks and is stupid that these spec files fail to run silently.
#
# # Tests if the file is valid.
# #
# # @param [String] path the file
# # @return [Boolean] when the file valid
# #
# def jasmine_spec?(path)
#   path =~ /(_|[.])spec\.(js|coffee|js\.coffee)$/ && File.exists?(path)
# end

guard 'jasmine',
  all_on_start: all_on_start,
  # server: :none,
  # server: :jasmine_gem,
  server: :none,
  server_mount: '/',
  jasmine_url: 'http://127.0.0.1:3000/jasmine',
  # verbose: true,
  phantomjs_bin: '\\bin\\phantomjs\\phantomjs192\\phantomjs',
  port: 8888 do

  # watch(%r{spec/javascripts\.(js\.coffee|js|coffee)$})         { "spec/javascripts" }
  # watch(%r{spec/javascripts/.+_spec\.(js\.coffee|js|coffee)$})
  watch(%r{^javascripts/(.+?)\.(js)$})  { |m|
    path = "spec/javascripts/#{m[1]}.spec.#{m[2]}"
    puts "Jasmine spec should run after this for #{path}"
    path
    # TODO:
    # The return value should actually be the specs that are to be run but
    # this doesn't seem to work at this time. The all_on_start does run all
    # the tests but I can't figure out a return value that actually makes
    # ANY specs run after a single file changes but the puts works before it.
    #
    # Funny, if I return "spec/javascripts" it tries and successfully does
    # run all the tests; however, if I am specific like
    #
    # spec/javascripts/core/api.spec.js
    #
    # Then it doesn't work. Can try some alternatives like without the filename
    # or without just the file extension.
    #
    # Doesn't work when set to spec/javascripts/core either. Weird.
    #
    # TODO:
    # Figured out an idea. Run the web server in a separate console and see
    # what pages are requested. Maybe can figure out what URL is requested
    # when given the return value below.
    # "spec/javascripts/core/api.spec.js"
  }
  watch(%r{^spec/(.+?\.js)$})  { |m|
    path = m[0]
    puts "Jasmine spec should run after this for #{path}"
    path
  }
end

# guard :jasmine,
#   server: :none,
#   server_mount: '/',
#   # verbose: true,
#   phantomjs_bin: '\\bin\\phantomjs\\phantomjs192\\phantomjs',
#   port: 8888 do
  
#   watch(%r{^javascripts/(.*)[.]js$}) { |m| "spec/javascripts" }
  
#   # watch(%r{^javascripts/(.*)[.]js$}) { |m| newest_js_file(spec_location % m[1]) }
#   # watch(%r{^spec/javascripts/(.*)[.][Ss]pec\..*}) { |m| newest_js_file(spec_location % m[1]) }
#   # watch(%r{^spec/javascripts/support/jasmine.yml})
  
#   # rackup_config:  'config.ru' do
#   # watch(%r{^javascripts/(.*)[.]js$}) { |m| newest_js_file(spec_location % m[1]) }
#   # watch(%r{^spec/javascripts/(.*)[.][Ss]pec\..*}) { |m| newest_js_file(spec_location % m[1]) }
#   # watch(%r{^spec/javascripts/support/jasmine.yml})
#   # watch(%r{spec/javascripts/spec\.(js\.coffee|js|coffee)$}) { 'spec/javascripts' }
#   # watch(%r{spec/javascripts/.+_spec\.js$})
#   # watch(%r{spec/javascripts/fixtures/.+$})
#   # watch(%r{app/assets/javascripts/(.+?)\.js(?:\.\w+)*$}) { |m| "spec/javascripts/#{ m[1] }_spec.#{ m[2] }" }
# end

# guard :jasmine,
#   server: :webrick,
#   # verbose: true,
#   phantomjs_bin: '\\bin\\phantomjs\\phantomjs192\\phantomjs',
#   rackup_config:  'config.ru' do
#   watch(%r{^javascripts/(.*)[.]js$}) { |m| newest_js_file(spec_location % m[1]) }
#   watch(%r{^spec/javascripts/(.*)[.][Ss]pec\..*}) { |m| newest_js_file(spec_location % m[1]) }
#   watch(%r{^spec/javascripts/support/jasmine.yml})
#   # watch(%r{spec/javascripts/spec\.(js\.coffee|js|coffee)$}) { 'spec/javascripts' }
#   # watch(%r{spec/javascripts/.+_spec\.(js\.coffee|js|coffee)$})
#   # watch(%r{spec/javascripts/fixtures/.+$})
#   # watch(%r{app/assets/javascripts/(.+?)\.(js\.coffee|js|coffee)(?:\.\w+)*$}) { |m| "spec/javascripts/#{ m[1] }_spec.#{ m[2] }" }
# end
