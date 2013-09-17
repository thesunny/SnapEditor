desc "Compiles CoffeeScript to JavaScript"
task :compile do
  # -b: bare - compile without a top-level function wrapper
  # -c: compile - compile to JavaScript and save as .js files
  # -l: lint - pipe the compiled JavaScript through JavaScript Lint
  # -o: output - set the output directory for compiled JavaScript
  sh "coffee -bcl -o javascripts coffeescripts"
end

desc "Build snapeditor.js"
task :build do
  sh "cd build && node r.js -o build.js"
end

desc "Build snapeditor.js for development"
task :build_dev do
  sh "cd build && node r.js -o build_dev.js"
end

desc "Compile and build snapeditor.js"
task :compileAndBuild => [:compile, :build]

namespace :prepare do
  def bundle(type)
    `markdown documentation/LICENSE.md > documentation/LICENSE.html`
    `markdown documentation/README.md > documentation/README.html`
    directory = File.join("bundle", type)
    mkdir_p directory
    rm_rf "#{directory}/snapeditor"
    mkdir_p "#{directory}/snapeditor"
    mkdir_p "#{directory}/snapeditor/lang"
    cp "documentation/LICENSE.md", "#{directory}/snapeditor/."
    cp "documentation/LICENSE.html", "#{directory}/snapeditor/."
    cp "documentation/README.md", "#{directory}/snapeditor/."
    cp "documentation/README.html", "#{directory}/snapeditor/."
    cp "documentation/example.html", "#{directory}/snapeditor/."
    cp "build/snapeditor.js", "#{directory}/snapeditor/."
    cp_r "spec/acceptance/assets/images", "#{directory}/snapeditor/."
    cp_r "spec/acceptance/assets/lang/en.js", "#{directory}/snapeditor/lang/."
    # zip usage: zip [options] <zip name without .zip> <directory to zip>
    #   -r: recursive (include subdirectories and files)
    `cd #{directory} && rm -f snapeditor.zip && zip -r snapeditor snapeditor/`
  end

  desc "Prepares snapeditor.js for testing"
  task :test => [:compile, :build] do
    cp "build/snapeditor.js", "spec/acceptance/assets/."
  end

  desc "Prepares the normal bundle for uploading"
  task :bundle_norm => [:compile, :build_dev] do
    bundle("norm")
  end

  desc "Prepares the minified bundle for uploading"
  task :bundle_min => [:compile, :build] do
    bundle("min")
  end

  desc "Prepare the bundle for uploading"
  task :bundle => [:bundle_norm, :bundle_min]
end
