define ["jquery.custom"], ($) ->
  class IFrame
    constructor: (options = {}) ->
      # Set defaults.
      options.class or= ""
      options.contents or= ""
      options.contentClass or= ""
      options.stylesheets or= []
      options.load or= ->

      $iframe = $("<iframe/>").on("load", ->
        @win = @contentWindow
        # NOTE: We use doc because IE doesn't like using document.
        @doc = @win.document
        @doc.open()
        @doc.write("<html><head>")

        # Load stylesheets if any.
        for stylesheet in options.stylesheets
          @doc.write("<link href=\"#{stylesheet}\" rel=\"stylesheet\" type=\"text/css\" />")

        # Write the contents.
        @doc.write("</head><body><div class=\"#{options.contentClass}\">#{options.contents}</body></html>")

        # Close writing.
        @doc.close()

        # Set the el.
        @el = $(@doc).find("div")[0]

        # Call the load function binding it to the iframe.
        options.load.apply(this)
      )
      $iframe.addClass(options.class) if options.class.length > 0

      return $iframe[0]

  return IFrame
