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
  desc "Prepares snapeditor.js for testing"
  task :test => [:compile, :build] do
    cp "build/snapeditor.js", "spec/acceptance/assets/javascripts"
  end

  desc "Prepare the bundle for uploading"
  task :bundle => [:compile, :build] do
    `markdown documentation/LICENSE.md > documentation/LICENSE.html`
    `markdown documentation/README.md > documentation/README.html`
    mkdir_p "bundle"
    mkdir_p "bundle/snapeditor-beta"
    mkdir_p "bundle/snapeditor-beta/javascripts"
    cp "documentation/LICENSE.md", "bundle/snapeditor-beta"
    cp "documentation/LICENSE.html", "bundle/snapeditor-beta"
    cp "documentation/README.md", "bundle/snapeditor-beta"
    cp "documentation/README.html", "bundle/snapeditor-beta"
    cp "build/snapeditor.js", "bundle/snapeditor-beta/javascripts"
    cp_r "spec/acceptance/assets/stylesheets", "bundle/snapeditor-beta/."
    cp_r "spec/acceptance/assets/templates", "bundle/snapeditor-beta/."
    cp_r "spec/acceptance/assets/images", "bundle/snapeditor-beta/."
    cp_r "spec/acceptance/assets/lang", "bundle/snapeditor-beta/."
    cp_r "spec/acceptance/assets/flash", "bundle/snapeditor-beta"
    `cd bundle && rm -f snapeditor-beta.zip && zip -r snapeditor-beta snapeditor-beta/`
  end
end
