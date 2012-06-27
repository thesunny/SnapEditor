require "json"

base_dir = File.dirname(File.expand_path(__FILE__))
# Don't cache. This is helpful because IE tends to cache all asynchronously
# loaded files. Since RequireJS is all about asynchronously loading files, the
# tests will load old files. This forces IE to always grab the latest files.
no_cache = {
  "Cache-Control" => "no-cache, no-store, max-age=0, must-revalidate",
  "Pragma" => "no-cache",
  "Expires" => "Fri, 29 Aug 1997 02:14:00 EST"
}
app = Proc.new do |env|
  request = Rack::Request.new(env)
  request.path_info = request.path_info.sub(base_dir, "")
  request.path_info = "/runner.html" if /^\/+$/.match(request.path_info)
  if request.path_info == "/snap_image_api"
    request_json = JSON.parse(request["json"])
    response_json = {
      status_code: 200,
      message: "Successful generation of image",
      image_url: "http://cuteoverload.files.wordpress.com/2012/03/2940609136_4c9e4bc47e_b.jpg?w=560&h=372",
      image_width: 560,
      image_height: 372
    }.to_json
    if request_json["response_content_type"]
      body = request_json["response_template"].gsub("{{json}}", response_json)
      header = { "Content-Type" => request_json["response_content_type"] }
    else
      body = response_json
      header = { "Content-Type" => "application/json" }
    end
    response = Rack::Response.new([body], 200, header.merge(no_cache))
  else
    response = Rack::File.new(".").call(request.env)
    response[1].merge!(no_cache)
  end
  response
end
run app
