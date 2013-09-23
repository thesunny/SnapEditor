# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom", "core/browser"], ($, Browser) ->
  class IFrame
    constructor: (options = {}) ->
      # Set defaults.
      options.write or= ->
      options.afterWrite or= ->
      options.load or= ->

      $iframe = $("<iframe/>").load(->
        # In Firefox, if we don't remove the "load" event, it continuously
        # triggers the event causing an infinite loop.
        # If we leave this in for Webkit, sometimes, when inserting the
        # iframe, the load still gets called but something happens and the
        # content gets overwritten by a very basic page (empty <html>,
        # <body>). I'm not sure what's going on but leaving this out for
        # Webkit.
        # If we take this out for IE, IE sometimes hangs. Leaving this in for
        # IE for now.
        # NOTE: It looks like Firefox no longer exhibits this behaviour.
        # However, I'm not sure which version is safe. Better to leave this in
        # here for a while as it does no harm in Firefox.
        $(this).off("load") unless Browser.isWebkit
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
