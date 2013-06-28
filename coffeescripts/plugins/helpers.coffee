define ["jquery.custom", "core/helpers"], ($, Helpers) ->
  return $.extend(Helpers,
    # Options:
    # * html
    # * langKey
    # * onInclude
    createButton: (button, shortcut, options = {}) ->
      text = SnapEditor.lang[options.langKey or button]
      cmd =
        text: text
        action: button
      if shortcut.length > 0
        cmd.onInclude = (e) ->
          SnapEditor.shortcuts[button] =
            key: shortcut
            action: button
          e.api.config.shortcuts.push(button)
          options.onInclude(e) if options.onInclude
      cmd.html = options.html
      cmd

    createStyles: (button, x) ->
      ".snapeditor_toolbar .snapeditor_toolbar_icon_#{Helpers.camelToSnake(button)} { background-position: #{x}px 0; }"
  )
