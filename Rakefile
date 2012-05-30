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

desc "Compile and build snapeditor.js"
task :compileAndBuild => [:compile, :build]

namespace :prepare do
  task :test => [:compile, :build] do
    cp "build/snapeditor.js", "spec/acceptance/assets/javascripts"
  end

  task :bundle => [:compile, :build] do
    mkdir_p "bundle"
    mkdir_p "bundle/javascripts"
    mkdir_p "bundle/stylesheets"
    mkdir_p "bundle/templates"
    mkdir_p "bundle/images"
    cp "build/snapeditor.js", "bundle/javascripts/snapeditor.js"
    cp "spec/acceptance/assets/stylesheets/snapeditor.css", "bundle/stylesheets"
    cp "spec/acceptance/assets/templates/snapeditor.html", "bundle/templates"
    cp "spec/acceptance/assets/images/toolbar.png", "bundle/images"
    cp "spec/acceptance/assets/images/contextmenu.png", "bundle/images"
  end
end
