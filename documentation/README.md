# Installation

Place the `snapeditor/` directory somewhere publicly accessible by your application. For example, in a `public/` directory.

# Integration

## Sourcing

Assuming the snapeditor code can be reached at `/snapeditor/javascripts/snapeditor.js`, you must source it before using the SnapEditor.

    <script type="text/javascript" src="/snapeditor/javascripts/snapeditor.js"></script>

## Content

The content you want to make editable must be wrapped in a `div` that can be referenced by a CSS selector.

    <div id="editor">
      <p>This inner content is all editable including the p tags, but not the div tag.</p>
    </div>

## Initialization

To initialize the SnapEditor, create a new SnapEditor.Inline or SnapEditor.Form object with the following arguments.

* DOM element or CSS selector
* Options hash
  * path: the URL path to the `snapeditor/` directory

Example.

    <script type="text/javascript">
      // DOM element
      var el = document.getElementById("form_editor")
      var formEditor = new SnapEditor.Form(el, { path: "/snapeditor" });
      // CSS selector
      var inlineEditor = new SnapEditor.Inline("#inline_editor", { path: "/snapeditor" });
    </script>

## Putting it all together

Full example.

    <html>
      <body>
        <div id="form_editor">
          <p>This is a form editor!</p>
        </div>
        <div id="inline_editor">
          <p>This is an inline editor!</p>
        </div>
        <script type="text/javascript" src="/snapeditor/javascripts/snapeditor.js"></script>
        <script type="text/javascript">
          // DOM element
          var el = document.getElementById("form_editor")
          var formEditor = new SnapEditor.Form(el, { path: "/snapeditor" });
          // CSS selector
          var inlineEditor = new SnapEditor.Inline("#inline_editor", { path: "/snapeditor" });
        </script>
      </body>
    </html>
