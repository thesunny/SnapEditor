# Browser Support

SnapEditor works in the following browsers.

* Firefox
* Chrome
* Safari (desktop)
* Microsoft Internet Explorer 7+

Coming soon.

* Opera
* Safari for iOS (iPad)

# SnapImage

SnapEditor comes with a sibling project called SnapImage to handle image uploading, resizing, and storing on the server. Before images can be used with SnapEditor, SnapImage must be installed.

You don't need to setup SnapImage in order to try out SnapEditor. However, the image feature will not work properly. If you're in a rush, skip down to [SnapEditor](#snapeditor).

## Rack-based Frameworks

For non-Rack-based frameworks, skip ahead to [Other Frameworks](#other_framworks).

For Rack-based frameworks, SnapImage comes in a RubyGem as a Rack middleware. You can install it like any other middleware.

### Gem

SnapImage is packaged in a RubyGem.

    gem install snapimage

### Config

SnapImage requires some configuration.

Generate a config file called `snapimage_config.yml`.

    snapimage_generate_config "/path/to/my/images/directory" "http://my-image-server.com/images"

The first argument is the path to a directory where the images will be stored.  The second argument is the URL where the images will be accessible.

You can move the config file anywhere. Just be sure to provide the correct path to the config file when using the middleware.

Help screen.

    snapimage_generate_config -h

### Usage

The class is `SnapImage::Middleware` with the following options:

* path: The URL to access the SnapImage API (defaults to "/snapimage\_api")
* config: Path to the YAML config file

Example.

    use SnapImage::Middleware, path: "/image_processor", config: "config/snapimage_config.yml"

Framework specific documentation:

* [Rails](http://guides.rubyonrails.org/rails_on_rack.html#configuring-middleware-stack)
* [Sinatra](http://www.sinatrarb.com/intro.html#Rack%20Middleware)

## <a id="other_framworks"></a>Other Frameworks

For those not using a Rack-based framework, we will be writing framework specific code in the near future. As a solution in the meantime, we have provided a server that can be run independently.

### Ruby

The SnapImage API server is written in [Sinatra](http://www.sinatrarb.com/) and requires [Ruby](http://www.ruby-lang.org/en/).

For help with installing Ruby, check out their [instructions](http://www.ruby-lang.org/en/downloads/).

### RubyGems

The SnapImage API server comes packaged in a [RubyGem](http://rubygems.org/) for easy distrubition.

For help with installing RubyGems, check out their [instructions](http://rubygems.org/pages/download).

### Config

The SnapImage API server requires some configuration.

Generate a config file called `snapimage_config.yml`.

    snapimage_generate_config "/path/to/my/images/directory" "http://my-image-server.com/images"

The first argument is the path to a directory where the images will be stored.  The second argument is the URL where the images will be accessible.

You can move the config file any where. Just be sure to provide the correct path to the config file when starting up the server.

Help screen.

    snapimage_generate_config -h

### Server

Start the SnapImage API server.

    snapimage_server path/to/config/file.yml

Help screen.

    snapimage_server -h

# <a id="snapeditor"></a>SnapEditor

## Installation

Place the `snapeditor/` directory somewhere publicly accessible by your application. For example, in a `public/` directory.

## Integration

## Sourcing

Assuming Snapeditor code can be reached at `/snapeditor/javascripts/snapeditor.js`, you must source it before using SnapEditor.

    <script type="text/javascript" src="/snapeditor/javascripts/snapeditor.js"></script>

### Form Content

Add an id to the `textarea` you want to make editable.

    <textarea id="editor" style="width: 600px; height: 400px;">
      <p>This content will be editable</p>
    </textarea>

### In-Place Content

Wrap the content you wish to make editable in a `div` with an id.

    <div id="editor">
      <p>This inner content is all editable including the p tags, but not the div tag.</p>
    </div>

### Initialization

To initialize SnapEditor, create a new SnapEditor.InPlace or SnapEditor.Form object with the following arguments.

* DOM element or id
* Options hash
  * path: the URL path to the `snapeditor/` directory
  * image: SnapImage API options
    * url: the URL to the SnapImage API
    * resource\_id: images are stored relative to the resource\_id

Form Editor using a DOM element.

    <script type="text/javascript">
      // DOM element
      var textarea = document.getElementById("editor");
      var formEditor = new SnapEditor.Form(textarea, {
        path: "/snapeditor",
        image: {
          url: "http://my-image-server.com/snapimage_api",
          resource_id: "unique_id"
        }
      });
    </script>

In-Place Editor using an id.

    <script type="text/javascript">
      // id
      var inPlaceEditor = new SnapEditor.InPlace("editor", {
        path: "/snapeditor",
        image: {
          url: "http://my-image-server.com/snapimage_api",
          resource_id: "unique_id"
        }
      });
    </script>

### Getting/Setting Content

The SnapEditor objects comes with public functions called getContents() and setContents() to get and set the contents of the editor respectively.

Use this instead of grabbing or setting the innerHTML from the editable element itself because SnapEditor runs certain checks before returning or setting the content.

    <script type="text/javascript">
      var inPlaceEditor = new SnapEditor.InPlace("editor", {
        path: "/snapeditor",
        image: {
          url: "http://my-image-server.com/snapimage_api",
          resource_id: "unique_id"
        }
      });
      var contents = inPlaceEditor.getContents();
      inPlaceEditor.setContents("<p>New contents.</p>");
    </script>

### Putting it all together

Form Editor full example.

    <!DOCTYPE html>
    <html>
      <body>
        <textarea id="editor" style="width: 600px; height: 400px;">
          <p>This content will be editable</p>
        </textarea>
        <script type="text/javascript" src="/snapeditor/javascripts/snapeditor.js"></script>
        <script type="text/javascript">
          // DOM element
          var textarea = document.getElementById("editor");
          var formEditor = new SnapEditor.Form(textarea, {
            path: "/snapeditor",
            image: {
              url: "http://my-image-server.com/snapimage_api",
              resource_id: "unique_id"
            }
          });
        </script>
      </body>
    </html>

In-Place Editor full example.

    <!DOCTYPE html>
    <html>
      <body>
        <div id="editor">
          <p>This is an in-place editor!</p>
        </div>
        <script type="text/javascript" src="/snapeditor/javascripts/snapeditor.js"></script>
        <script type="text/javascript">
          // id
          var inPlaceEditor = new SnapEditor.InPlace("editor", {
            path: "/snapeditor",
            image: {
              url: "http://my-image-server.com/snapimage_api",
              resource_id: "unique_id"
            }
          });
        </script>
      </body>
    </html>
