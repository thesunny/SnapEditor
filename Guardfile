# More info at https://github.com/guard/guard#readme
spec_location = "spec/javascripts/%s.spec"

# uncomment if you use NerdCapsSpec.js
# spec_location = "spec/javascripts/%sSpec"

guard "coffeescript", input: "coffeescripts", output: "javascripts", bare: true, shallow: false do
  # TODO: Figure out a better way to build the project. Perhaps create a custom
  # guard.
  watch(%r{^javascripts/.*[.]js}) { `cd build && node r.js -o build.js` }
end

guard "jasmine-headless-webkit" do
  watch(%r{^javascripts/(.*)[.]js$}) { |m| newest_js_file(spec_location % m[1]) }
  watch(%r{^spec/javascripts/(.*)[.][Ss]pec\..*}) { |m| newest_js_file(spec_location % m[1]) }
  watch(%r{^spec/javascripts/support/jasmine.yml})
end
