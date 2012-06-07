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
    `markdown documentation/LICENSE.md > documentation/LICENSE.html`
    `markdown documentation/README.md > documentation/README.html`
    mkdir_p "bundle"
    mkdir_p "bundle/snapeditor"
    mkdir_p "bundle/snapeditor/javascripts"
    mkdir_p "bundle/snapeditor/stylesheets"
    mkdir_p "bundle/snapeditor/templates"
    mkdir_p "bundle/snapeditor/images"
    cp "documentation/LICENSE.md", "bundle/snapeditor"
    cp "documentation/LICENSE.html", "bundle/snapeditor"
    cp "documentation/README.md", "bundle/snapeditor"
    cp "documentation/README.html", "bundle/snapeditor"
    cp "build/snapeditor.js", "bundle/snapeditor/javascripts"
    cp "spec/acceptance/assets/stylesheets/snapeditor.css", "bundle/snapeditor/stylesheets"
    cp "spec/acceptance/assets/templates/snapeditor.html", "bundle/snapeditor/templates"
    cp_r "spec/acceptance/assets/images", "bundle/snapeditor"
    `zip -r bundle/snapeditor bundle/snapeditor/`
  end
end
