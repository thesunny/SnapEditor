# Installation

Place the `snapeditor/` directory somewhere publicly accessible by your application. For example, in a `public/` directory.

# Integration

## Sourcing

Assuming Snapeditor code can be reached at `/snapeditor/javascripts/snapeditor.js`, you must source it before using SnapEditor.

    <script type="text/javascript" src="/snapeditor/javascripts/snapeditor.js"></script>

## Content

Wrap the content you wish to make editable in a `div` with an id.

    <div id="editor">
      <p>This inner content is all editable including the p tags, but not the div tag.</p>
    </div>

## Initialization

To initialize SnapEditor, create a new SnapEditor.InPlace or SnapEditor.Form object with the following arguments.

* DOM element or id
* Options hash
  * path: the URL path to the `snapeditor/` directory

Form Editor using a DOM element.

    <script type="text/javascript">
      // DOM element
      var el = document.getElementById("editor")
      var formEditor = new SnapEditor.Form(el, { path: "/snapeditor" });
    </script>

In-Place Editor using an id.

    <script type="text/javascript">
      // id
      var inPlaceEditor = new SnapEditor.InPlace("editor", { path: "/snapeditor" });
    </script>

## Getting Content

The SnapEditor objects comes with a public function called getContents() to get the contents of the editor.

Use this instead of grabbing the innerHTML from the editable element itself because SnapEditor runs certain checks before returning the content.

    <script type="text/javascript">
      var inPlaceEditor = new SnapEditor.InPlace("editor", { path: "/snapeditor" });
      var contents = inPlaceEditor.getContents()
    </script>

## Putting it all together

Form Editor full example.

    <html>
      <body>
        <div id="editor">
          <p>This is a form editor!</p>
        </div>
        <script type="text/javascript" src="/snapeditor/javascripts/snapeditor.js"></script>
        <script type="text/javascript">
          // DOM element
          var el = document.getElementById("editor")
          var formEditor = new SnapEditor.Form(el, { path: "/snapeditor" });
        </script>
      </body>
    </html>

In-Place Editor full example.

    <html>
      <body>
        <div id="editor">
          <p>This is an in-place editor!</p>
        </div>
        <script type="text/javascript" src="/snapeditor/javascripts/snapeditor.js"></script>
        <script type="text/javascript">
          // id
          var inPlaceEditor = new SnapEditor.InPlace("editor", { path: "/snapeditor" });
        </script>
      </body>
    </html>
