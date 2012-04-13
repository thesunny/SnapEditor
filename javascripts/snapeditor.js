// This require is specific to almond.js and not require.js.
// The third argument is the relName. We don't need it so we set it to null.
// The fourth argument is set to true for loading the editor synchronously.
// This is needed so that the SnapEditor object is available immediately.
require(["cs!core/editor"], function (Editor) {
  window.SnapEditor = Editor;
}, null, true);
