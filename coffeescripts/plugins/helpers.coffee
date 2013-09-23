# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom", "core/helpers"], ($, Helpers) ->
  return $.extend(Helpers,
    # Options:
    # * html
    # * langKey
    # * onInclude
    createButton: (name, shortcut, options = {}) ->
      text: SnapEditor.lang[options.langKey or name]
      html: options.html
      action: name
      onInclude: (e) ->
        if shortcut.length > 0
          SnapEditor.shortcuts[name] =
            key: shortcut
            action: name
          e.api.config.shortcuts.push(name)
        options.onInclude(e) if options.onInclude

    createStyles: (button, x) ->
      ".snapeditor_toolbar .snapeditor_toolbar_icon_#{Helpers.camelToSnake(button)} { background-position: #{x}px 0; }"
  )
