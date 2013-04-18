define ["jquery.custom", "core/helpers", "lang/en", "ui/ui.dialog"], ($, Helpers, LangEn, Dialog) ->
  unless window.SnapEditor
    window.SnapEditor =
      #
      # PUBLIC
      #

      version: "1.6.0"
      lang: LangEn
      buttons: {}
      behaviours: {}
      shortcuts: {}
      actions: {}
      InPlace: {}
      Form: {}
      Dialog: Dialog
      debug: false

      #
      # PRIVATE
      #

      insertedStyles: {}

      # Inserts the given styles into the head of the document.
      # The id is used to ensure duplicate styles are not added.
      insertStyles: (id, styles) ->
        unless @insertedStyles[id]
          Helpers.insertStyles(styles)
          @insertedStyles[id] = true

      getPath: ->
        unless @path
          for script in $("script")
            match = @matchPath($(script).attr("src"))
            if match
              @path = match
              break
          throw "Error finding the SnapEditor path!" unless @path
        @path

      matchPath: (src) ->
        path = null
        match = /^(|.*\/)snapeditor.js$/.exec(src)
        if match
          path = match[1]
          path = "." if path == ""
        path

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
