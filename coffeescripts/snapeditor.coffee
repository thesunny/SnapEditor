# This require is specific to almond.js and not require.js.
# The third argument is the relName. We don't need it so we set it to null.
# The fourth argument is set to true for loading the editor synchronously.
# This is needed so that the SnapEditor object is available immediately.
require ["core/editor.inline", "core/editor.form"], ((InlineEditor, FormEditor) ->
  window.SnapEditor =
    Inline: InlineEditor
    Form: FormEditor
), null, true
