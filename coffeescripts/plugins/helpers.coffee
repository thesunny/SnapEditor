define ["jquery.custom", "core/helpers"], ($, Helpers) ->
  return $.extend(Helpers,
    # Options:
    # * html
    # * langKey
    createButton: (button, shortcut, actionHandler, options = {}) ->
      text = SnapEditor.lang[options.langKey or button]
      cmd =
        text: text
        action: actionHandler
      cmd.shortcut = shortcut if shortcut.length > 0
      cmd.html = options.html
      cmd

    createStyles: (button, x) ->
      ".snapeditor_toolbar .snapeditor_toolbar_icon_#{Helpers.camelToSnake(button)} { background-position: #{x}px 0; }"
  )
