# More info at https://github.com/guard/guard#readme
spec_location = "spec/javascripts/%s.spec"

# uncomment if you use NerdCapsSpec.js
# spec_location = "spec/javascripts/%sSpec"

guard :coffeescript, input: "coffeescripts", output: "javascripts", bare: true, shallow: false, all_on_start: true

guard :shell, all_on_start: false do
  watch(%r{^javascripts/.*[.]js}) do |m|
    output = `cd build && node r.js -o build.js`
    if $?.to_i == 0
      n "Successfully built build/snapeditor.js", "Build Successful", :success
    else
      n "Please check console for errors", "Build Failed", :failed
    end
    output
  end
end

guard "jasmine-headless-webkit", all_on_start: false do
  watch(%r{^javascripts/(.*)[.]js$}) { |m| newest_js_file(spec_location % m[1]) }
  watch(%r{^spec/javascripts/(.*)[.][Ss]pec\..*}) { |m| newest_js_file(spec_location % m[1]) }
  watch(%r{^spec/javascripts/support/jasmine.yml})
end
