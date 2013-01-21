define ["jquery.custom"], ($) ->
  class IFrame
    constructor: (options = {}) ->
      # Set defaults.
      options.write or= ->
      options.afterWrite or= ->
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
        options.write.apply(this)
        @doc.close()
        options.afterWrite.apply(this)

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

      return $iframe[0]
