# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["snapeditor.pre", "jquery.custom", "plugins/helpers"], (SnapEditor, $, Helpers) ->
  formatInline = (e) -> e.api.clean() if e.api.formatInline(e.type)
  SnapEditor.defActions
    bold: formatInline
    italic: formatInline
    underline: formatInline
    subscript: formatInline
    superscript: formatInline
    strikethrough: formatInline
  # TODO:
  # Currently there are no unit tests to make sure all of these are defined
  # properly. So I made the change to use defActions but the old style is still
  # here; however, I left the code below in as comments in case I messed it up.
  #
  # SnapEditor.actions.bold = formatInline
  # SnapEditor.actions.italic = formatInline
  # SnapEditor.actions.underline = formatInline
  # SnapEditor.actions.subscript = formatInline
  # SnapEditor.actions.superscript = formatInline
  # SnapEditor.actions.strikethrough = formatInline

  SnapEditor.defButtons
    bold: Helpers.createButton("bold", "ctrl+b", onInclude: (e) -> e.api.addWhitelistRule(Bold: "b", strong: "Bold"))
    italic: Helpers.createButton("italic", "ctrl+i", onInclude: (e) -> e.api.addWhitelistRule(Italic: "i", em: "Italic"))
    underline: Helpers.createButton("underline", "ctrl+u", onInclude: (e) -> e.api.addWhitelistRule("Underline", "u"))
    subscript: Helpers.createButton("subscript", "ctrl+shift+-", onInclude: (e) -> e.api.addWhitelistRule("Subscript", "sub"))
    superscript: Helpers.createButton("superscript", "ctrl+shift+=", onInclude: (e) -> e.api.addWhitelistRule("Superscript", "sup"))
    strikethrough: Helpers.createButton("strikethrough", "ctrl+-", onInclude: (e) -> e.api.addWhitelistRule(Strikethrough: "del", strike: "Strikethrough"))

  styles = ""
  for button, i in ["bold", "italic", "underline", "subscript", "superscript", "strikethrough"]
    styles += Helpers.createStyles(button, i * -26) # sprite position * step
  SnapEditor.insertStyles("plugins_inline", styles)
