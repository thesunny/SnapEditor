define ["jquery.custom", "core/iframe"], ($, IFrame) ->
  class IFrameSnapEdtor extends IFrame
    constructor: (options = {}) ->
      # Set defaults.
      classname = options.class or ""
      contents = options.contents or ""
      contentClass = options.contentClass or ""
      stylesheets = options.stylesheets or []
      options.load or= ->

      options.write = ->
        @doc.write("<!DOCTYPE html><html style=\"height: 100%; padding: 0; overflow-y: scroll;\"><head>")
        # Load stylesheets if any.
        for stylesheet in stylesheets
          @doc.write("<link href=\"#{stylesheet}\" rel=\"stylesheet\" type=\"text/css\" />")
        # Write the contents.
        @doc.write("</head><body style=\"height: 100%;\"><div class=\"#{contentClass}\" style=\"height: 100%;\">#{contents}</div></body></html>")

      options.afterWrite = ->
        @el = $(@doc).find("div")[0]

      iframe = super(options)
      $(iframe).addClass(classname) if classname.length > 0
      return iframe
