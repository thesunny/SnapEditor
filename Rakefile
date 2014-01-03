# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
desc "Compiles CoffeeScript to JavaScript"
task :compile do
  # -b: bare - compile without a top-level function wrapper
  # -c: compile - compile to JavaScript and save as .js files
  # -l: lint - pipe the compiled JavaScript through JavaScript Lint
  # -o: output - set the output directory for compiled JavaScript
  sh "coffee -bcl -o javascripts coffeescripts"
end

def get_script_files
  regexp = /[.]\/coffeescripts\/(.*)[.]coffee/
  files = Dir.glob("./coffeescripts/**/*.coffee").map do |path|
    regexp.match(path)[1]
  end
end

def join_build_scripts(type)
  require "json"
  build_object = JSON.parse(File.read("./build/build_#{type}.js"))
  paths_object = JSON.parse(File.read("./build/build_path.js"))
  include_object = {"include" => get_script_files }
  output_json = JSON.pretty_generate(build_object.merge(paths_object).merge(include_object))
  # puts output_json
  File.open("./build/build_#{type}_gen.js", "w") do |io|
    io.write(output_json)
  end
end

desc "Run Jasmine Web Service"
task :spec_server do
  sh "bundle exec rackup -p 3000"
end

# Puts the Javascripts together. It doesn't do anything with
# respect to the original .coffee files.
desc "Build snapeditor.js"
task :build do
  sh "cd build && node r.js -o build.js"
end

# Puts the Javascripts together. It doesn't do anything with
# respect to the original .coffee files.
desc "Build snapeditor.js for development"
task :build_dev do
  sh "cd build && node r.js -o build_dev.js"
end

# Puts the Javascripts together. It doesn't do anything with
# respect to the original .coffee files.
desc "Build snapeditor.js for running specs"
task :build_spec do
  join_build_scripts "spec"
  sh "cd build && node r.js -o build_spec_gen.js"
end

desc "Compile and build snapeditor.js"
task :compileAndBuild => [:compile, :build]

desc "Compile and build snapeditor.js for dev"
task :prep_for_spec => [:compile, :build_spec]

# Guard compiles the Coffeescript files to JavaScript when they change so we
# only need to build the dev version and the spec version.
desc "Build snapeditor_dev.js and snapeditor_spec.js for Guard"
task :build_for_guard => [:build_dev, :build_spec]

namespace :prepare do
  # Prepares the bundle for the release
  def bundle(type)
    directory = File.join("bundle", type)
    mkdir_p directory
    rm_rf "#{directory}/snapeditor"
    mkdir_p "#{directory}/snapeditor"
    mkdir_p "#{directory}/snapeditor/lang"
    cp "COPYING", "#{directory}/snapeditor/."
    cp "COPYING.LESSER", "#{directory}/snapeditor/."
    cp "build/snapeditor.js", "#{directory}/snapeditor/."
    cp_r "spec/acceptance/assets/images", "#{directory}/snapeditor/."
    cp_r "documentation", "#{directory}/snapeditor/."
    mv "#{directory}/snapeditor/documentation/example.html", "#{directory}/snapeditor/."
    cp_r "spec/acceptance/assets/lang", "#{directory}/snapeditor/."
    # TODO:
    # Make this work in windows probably by using pkzip or some other free
    # zip software.
    #
    # zip usage: zip [options] <zip name without .zip> <directory to zip>
    #   -r: recursive (include subdirectories and files)
    `cd #{directory} && rm -f snapeditor.zip && zip -r snapeditor snapeditor/`
  end

  # Creates a test version for testers to use that can be updated separately
  # from the build that we use for development. This lets us dev and test
  # concurrently.
  #
  # Can be found in /spec/acceptance/test.html
  #
  # NOTE: test.html hasn't been updated in some time.
  desc "Prepares snapeditor.js for testing"
  task :test => [:compile, :build] do
    cp "build/snapeditor.js", "spec/acceptance/assets/."
  end

  # Part of bundle (not minified)
  desc "Prepares the normal bundle for uploading"
  task :bundle_norm => [:compile, :build_dev] do
    bundle("norm")
  end

  # Part of bundle (minified)
  desc "Prepares the minified bundle for uploading"
  task :bundle_min => [:compile, :build] do
    bundle("min")
  end

  # Runs both bundling method
  desc "Prepare the bundle for uploading"
  task :bundle => [:bundle_norm, :bundle_min]
end

begin
  require 'jasmine'
  load 'jasmine/tasks/jasmine.rake'
rescue LoadError
  task :jasmine do
    abort "Jasmine is not available. In order to run jasmine, you must: (sudo) gem install jasmine"
  end
end
