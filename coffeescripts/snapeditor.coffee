# This require is specific to almond.js and not require.js.
# The third argument is the relName. We don't need it so we set it to null.
# The fourth argument is set to true for loading the editor synchronously.
# This is needed so that the SnapEditor object is available immediately.
require ["core/browser", "core/editor.in_place", "core/editor.form", "core/editor.unsupported"], ((Browser, InPlaceEditor, FormEditor, UnsupportedEditor) ->
  window.SnapEditor =
    version: "1.0.0"
    InPlace: if Browser.isSupported then InPlaceEditor else UnsupportedEditor
    Form: if Browser.isSupported then FormEditor else UnsupportedEditor
  #if typeof console != "undefined" and typeof console.log != "undefined"
    #console.log("This is a beta release of the SnapEditor. Check it out at http://snapeditor.com.")
), null, true
