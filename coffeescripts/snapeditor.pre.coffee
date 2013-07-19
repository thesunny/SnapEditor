define ["jquery.custom", "core/helpers", "lang/en", "ui/ui.dialog"], ($, Helpers, LangEn, Dialog) ->
  window.SnapEditor or= {}
  $.extend(window.SnapEditor,
    #
    # PUBLIC
    #

    version: "1.8.3"
    lang: window.SnapEditor.lang or LangEn
    buttons: {}
    behaviours: {}
    shortcuts: {}
    actions: {}
    InPlace: {}
    Form: {}
    Dialog: Dialog
    debug: false

    # Arguments
    # * selector - CSS selector that will be applied
    # * style - object
    #   * text
    #   * html
    #   * shortcut - only for internal plugin use
    addStyleButton: (selector, style) ->
      throw "The style button #{selector} is already defined." if SnapEditor.buttons[selector]

      tags =
        p: "style-block"
        div: "style-block"
        h1: "style-block"
        h2: "style-block"
        h3: "style-block"
        h4: "style-block"
        h5: "style-block"
        h6: "style-block"
        table: "style-table"
        tr: "style-table-row"
        th: "style-table-cell"
        td: "style-table-cell"

      SnapEditor.actions[selector] = (e) -> e.api.styleBlock(selector)
      SnapEditor.buttons[selector] =
        text: style.text
        html: style.html
        action: selector
        onInclude: (e) ->
          e.api.addWhitelistRule(Helpers.capitalize(selector), selector)
          if style.shortcut
            SnapEditor.shortcuts[selector] =
              key: style.shortcut
              action: selector
            e.api.config.shortcuts.push(selector)
        tags: ["style", tags[selector.split(".")[0]]]

    addStyleButtons: (styles) ->
      @addStyleButton(selector, style) for own selector, style of styles

    addStyleList: (name, text, tags) ->
      tags = $.makeArray(tags)
      SnapEditor.buttons[name] =
        text: text
        items: (e) ->
          items = []
          for tag in tags
            items = items.concat(e.api.getStyleButtonsByTag(tag))
            items.push("|")
          # Pop the last "|"
          items.pop()
          items
        onRender: (e) ->
          e.button.state.visible = e.button.getItems(e).length > 1

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
  )
