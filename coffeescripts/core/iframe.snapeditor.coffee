# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom", "core/browser", "core/iframe"], ($, Browser, IFrame) ->
  class IFrameSnapEdtor extends IFrame
    constructor: (options = {}) ->
      # Set defaults.
      classname = options.class or ""
      contents = options.contents or ""
      contentClass = options.contentClass or ""
      stylesheets = options.stylesheets or []
      styles = options.styles or ""
      options.load or= ->

      options.write = ->
        # Webkit requires the <html>, <body>, and <div> tags to have a height
        # of 100% in order for the whitespace underneath the content to be
        # clickable. This has been left in for all other browsers as there are
        # no effects, except for in IE7. IE7 craps out when setting height of
        # 100% because the body is set to 100% height of the viewable port,
        # not the entire document. This causes problems when clicking in
        # whitepsace below the height of the body. Basically when clicking in
        # whitespace below the height of the body, no range is created.
        htmlStyle = "padding: 0; overflow-y: scroll;"
        htmlStyle += "height: 100%;" unless Browser.isIE7
        @doc.write("<!DOCTYPE html><html style=\"#{htmlStyle}\"><head>")
        # Load stylesheets if any.
        for stylesheet in stylesheets
          @doc.write("<link href=\"#{stylesheet}\" rel=\"stylesheet\" type=\"text/css\" />")
        # Load styles if any.
        if $.trim(styles).length > 0
          @doc.write("<style>#{styles}</style>")
        # Write the contents.
        contentStyle = if Browser.isIE7 then "" else "height: 100%"
        @doc.write("</head><body style=\"#{contentStyle}\"><div class=\"#{contentClass}\" style=\"#{contentStyle}\">#{contents}</div></body></html>")

      options.afterWrite = ->
        @el = $(@doc).find("div")[0]

      iframe = super(options)
      $(iframe).addClass(classname) if classname.length > 0
      return iframe
