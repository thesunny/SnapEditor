
require(["core/editor.snap", "core/editor.form"], (function(SnapEditor, FormEditor) {
  return window.SnapEditor = {
    Snap: SnapEditor,
    Form: FormEditor
  };
}), null, true);
