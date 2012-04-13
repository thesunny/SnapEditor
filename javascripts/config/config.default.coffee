define ["cs!plugins/activate/activate", "cs!plugins/editable/editable", "cs!plugins/inline_styler/inline_styler"], (Activate, Editable, InlineStyler) ->
  return {
    plugins: [new Activate(), new Editable(), new InlineStyler()],
    toolbar: [
      ["Bold", "Italic"]
    ]
  }
