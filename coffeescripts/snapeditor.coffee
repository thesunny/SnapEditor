# This require is specific to almond.js and not require.js.
# The third argument is the relName. We don't need it so we set it to null.
# The fourth argument is set to true for loading the editor synchronously.
# This is needed so that the SnapEditor object is available immediately.
require ["jquery.custom", "snapeditor.pre", "core/browser", "core/editor.in_place", "core/editor.form", "core/editor.unsupported"], (($, Pre, Browser, InPlaceEditor, FormEditor, UnsupportedEditor) ->
  # NOTE: Most of the SnapEditor stuff is in snapeditor.pre.coffee. This is so
  # that the other modules have access to the SnapEditor object.
  $.extend(window.SnapEditor,
    InPlace: if Browser.isSupported then InPlaceEditor else UnsupportedEditor
    Form: if Browser.isSupported then FormEditor else UnsupportedEditor
  )
), null, true
