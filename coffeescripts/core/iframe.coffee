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
        # In Firefox, if we don't remove the "load" event, it continuously
        # triggers the event causing an infinite loop. This is left in for
        # other browsers as there is no harm.
        $(this).off("load")
        @win = @contentWindow
        # NOTE: We use doc because IE doesn't like using document.
        @doc = @win.document
        @doc.open()
        @doc.write("<!DOCTYPE html><html style=\"height: 100%; padding: 0; overflow-y: scroll;\"><head>")

        # Load stylesheets if any.
        for stylesheet in options.stylesheets
          @doc.write("<link href=\"#{stylesheet}\" rel=\"stylesheet\" type=\"text/css\" />")

        # Write the contents.
        @doc.write("</head><body style=\"height: 100%;\"><div class=\"#{options.contentClass}\" style=\"height: 100%;\">#{options.contents}</body></html>")

        # Close writing.
        @doc.close()

        # Set the el.
        @el = $(@doc).find("div")[0]

        # Add needed functions.
        @createElement = (name) => @doc.createElement(name)
        @find = (selector) ->
          matches = $(@doc).find(selector)
          switch matches.length
            when 0 then return null
            when 1 then return matches[0]
            else return matches.toArray()

        # Call the load function binding it to the iframe.
        options.load.apply(this)
      )
      $iframe.addClass(options.class) if options.class.length > 0

      return $iframe[0]

  return IFrame
