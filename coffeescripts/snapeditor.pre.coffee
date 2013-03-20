define ["jquery.custom", "core/helpers", "lang/en", "core/ui/ui.dialog"], ($, Helpers, LangEn, Dialog) ->
  unless window.SnapEditor
    window.SnapEditor =
      #
      # PUBLIC
      #

      version: "1.4.0"
      lang: LangEn
      commands: {}
      plugins: {}
      Dialog: Dialog
      debug: false

      #
      # PRIVATE
      #

      insertedStyles: {}
      internalCommands: {}
      internalPlugins: {}

      # Inserts the given styles into the head of the document.
      # The id is used to ensure duplicate styles are not added.
      insertStyles: (id, styles) ->
        unless @insertedStyles[id]
          Helpers.insertStyles(styles)
          @insertedStyles[id] = true

      getAllCommands: ->
        unless @allCommands
          @allCommands = {}
          for name, plugin of @internalPlugins
            @allCommands[key] = command for key, command of plugin.commands || {}
          for name, plugin of @plugins
            for key, command of plugin.commands || {}
              @allCommands[key] = command
          $.extend(@allCommands, @internalCommands)
          $.extend(@allCommands, @commands)
        @allCommands

      getAllPlugins: ->
        unless @allPlugins
          @allPlugins = {}
          $.extend(@allPlugins, @internalPlugins)
          $.extend(@allPlugins, @plugins)
        @allPlugins

      DEBUG: ->
        if @debug
          if typeof console != "undefined" and typeof console.log != "undefined"
            if typeof console.log.apply == "undefined"
              console.log(a) for a in arguments
            else
              console.log(arguments...)
          # TODO: The below else is untested. Commenting out for now since we don't
          # need it.
          #else
            #$log = $("#snapeditor_logger") or
              #$("<div/>").
                #attr("id", "snapeditor_logger").
                #css(
                  #width: 600
                  #height: 400
                  #overflow: auto
                #).
                #appendTo("body")
            #$log.append(a).append("<br>") for a in arguments
