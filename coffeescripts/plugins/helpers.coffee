define ["jquery.custom", "core/helpers"], ($, Helpers) ->
  return $.extend(Helpers,
    # Options:
    # * html
    # * langKey
    createCommand: (command, shortcut, actionHandler, options = {}) ->
      text = SnapEditor.lang[options.langKey or command]
      cmd =
        text: text
        action: actionHandler
      cmd.shortcut = shortcut if shortcut.length > 0
      cmd.html = options.html
      cmd

    createStyles: (command, x) ->
      ".snapeditor_toolbar .snapeditor_toolbar_icon_#{Helpers.camelToSnake(command)} { background-position: #{x}px 0; }"
  )
