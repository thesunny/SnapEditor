# This require is specific to almond.js and not require.js.
# The third argument is the relName. We don't need it so we set it to null.
# The fourth argument is set to true for loading the editor synchronously.
# This is needed so that the SnapEditor object is available immediately.
require ["core/browser", "core/editor.in_place", "core/editor.form", "core/editor.unsupported"], ((Browser, InPlaceEditor, FormEditor, UnsupportedEditor) ->
  window.SnapEditor =
    version: "1.1.0"
    InPlace: if Browser.isSupported then InPlaceEditor else UnsupportedEditor
    Form: if Browser.isSupported then FormEditor else UnsupportedEditor
    debug: false
    DEBUG: ->
      if @debug and typeof console != "undefined" and typeof console.log != "undefined"
        if typeof console.log.apply == "undefined"
          console.log(a) for a in arguments
        else
          console.log(arguments...)
      #else
        #alert(a) for a in arguments
    widgets: {}
  #if typeof console != "undefined" and typeof console.log != "undefined"
    #console.log("This is a beta release of the SnapEditor. Check it out at http://snapeditor.com.")
), null, true
