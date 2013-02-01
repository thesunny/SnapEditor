# This require is specific to almond.js and not require.js.
# The third argument is the relName. We don't need it so we set it to null.
# The fourth argument is set to true for loading the editor synchronously.
# This is needed so that the SnapEditor object is available immediately.
require ["jquery.custom", "core/browser", "core/editor.in_place", "core/editor.form", "core/editor.unsupported"], (($, Browser, InPlaceEditor, FormEditor, UnsupportedEditor) ->
  log =  ->
    if typeof console != "undefined" and typeof console.log != "undefined"
      if typeof console.log.apply == "undefined"
        console.log(a) for a in arguments
      else
        console.log(arguments...)
    # TODO: The below else is untested. Commenting out for now since we don't
    # need it.
    #else
      #$log = $("#snapeditor_logger") or
        #$("<div/>").
          #attr("id", "snapeditor_logger").
          #css(
            #width: 600
            #height: 400
            #overflow: auto
          #).
          #appendTo("body")
      #$log.append(a).append("<br>") for a in arguments

  window.SnapEditor =
    version: "1.1.0"
    InPlace: if Browser.isSupported then InPlaceEditor else UnsupportedEditor
    Form: if Browser.isSupported then FormEditor else UnsupportedEditor
    debug: false
    DEBUG: ->
      log.apply(this, arguments) if @debug
), null, true
