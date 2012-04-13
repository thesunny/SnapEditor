# More info at https://github.com/guard/guard#readme
spec_location = "spec/javascripts/%s_spec"

# uncomment if you use NerdCapsSpec.js
# spec_location = "spec/javascripts/%sSpec"

guard 'jasmine-headless-webkit' do
  watch(%r{^javascripts/.*[.]coffee}) { `cd build && node r.js -o build.js` }
  watch(%r{^javascripts/.*[.]coffee}) { `jasmine-headless-webkit` }
  watch(%r{^spec/javascripts/.*[.]coffee}) { `jasmine-headless-webkit` }
  watch(%r{^spec/javascripts/support/jasmine.yml}) { `jasmine-headless-webkit` }
end
