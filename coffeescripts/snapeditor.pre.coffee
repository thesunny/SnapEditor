# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom", "core/helpers", "lang/en", "core/dialog/dialog", "snapeditor.helpers"], ($, Helpers, LangEn, Dialog, SnapEditorHelpers) ->
  window.SnapEditor or= {}
  $.extend(window.SnapEditor, SnapEditorHelpers,
    #
    # PUBLIC
    #

    version: "2.0.0"
    lang: window.SnapEditor.lang or LangEn
    buttons: {}
    behaviours: {}
    shortcuts: {}
    actions: {}
    widgets: {}
    dialogs: {}
    InPlace: {}
    Form: {}
    zIndexBase: window.SnapEditor.zIndexBase or 100
    debug: false

    # Arguments
    # * selector - CSS selector that will be applied
    # * style - object
    #   * text
    #   * html
    #   * newline - only for non-TD/TH
    #   * shortcut - only for internal plugin use
    addStyleButton: (selector, style) ->
      # The key in this case represents the unique name for this button.
      # getStyleKey prefixes it to help avoid collisions.
      key = @getStyleKey(selector)
      throw "The style button #{selector} is already defined." if SnapEditor.buttons[key]

      tags =
        p: "style-block"
        div: "style-block"
        h1: "style-block"
        h2: "style-block"
        h3: "style-block"
        h4: "style-block"
        h5: "style-block"
        h6: "style-block"
        pre: "style-block"
        table: "style-table"
        tr: "style-table-row"
        th: "style-table-cell"
        td: "style-table-cell"

      SnapEditor.actions[key] = (e) ->
        e.api.styleBlock(selector)
        e.api.clean()
      SnapEditor.buttons[key] =
        text: style.text
        html: style.html
        action: key
        onInclude: (e) ->
          tag = selector.split(".").shift()
          # This section creates the rule which is based off of the selector
          # and then also specifies what happens after you hit ENTER. That
          # part is specified after the ">"
          rule = selector
          if $.inArray(tag, ["td", "th"]) > -1
            rule += " > BR"
          else if style.newline
            rule += " > #{style.newline}"
          e.api.addWhitelistRule(Helpers.capitalize(key), rule)
          # TODO: Consider setting the SnapEditor.shortcuts outside of
          # onInclude and just leave the e.api.config.shortcuts.push(key)
          # here.
          if style.shortcut
            SnapEditor.shortcuts[key] =
              key: style.shortcut
              action: key
            e.api.config.shortcuts.push(key)
        tags: ["style", tags[selector.split(".")[0]]]

    addStyleButtons: (styles) ->
      @addStyleButton(selector, style) for own selector, style of styles

    addStyleList: (name, text, tags) ->
      tags = $.makeArray(tags)
      SnapEditor.buttons[name] =
        text: text
        items: (e) ->
          items = []
          # We add the style buttons in groups by tag. Between groups we add
          # a "|" as a separator. At the end, we pop off the last one because
          # we don't need it.
          for tag in tags
            items = items.concat(e.api.getStyleButtonsByTag(tag))
            items.push("|")
          # Pop the last "|"
          items.pop()
          items
        # This gets called before this individual button render happens.
        # If there is nothing here, we don'ot need to display it.
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
      # TODO: Made the match path a little looser so that it can accept
      # snapeditor_SOMETHING.js as well as snapeditor.js
      match = /^(|.*\/)snapeditor(_[^.]+)?.js$/.exec(src)
      if match
        path = match[1]
        path = "." if path == ""
      path

    getStyleKey: (selector) ->
      # We namespace the custom style's name so that it doesn't overwrite
      # a button with the same name.
      "customStyle#{Helpers.capitalize(selector)}"

    getSelectorFromStyleKey: (key) ->
      key.replace(/^customStyle/, "").toLowerCase()

    createdDialogs: {}

    openDialog: (type, event, args) ->
      @createdDialogs[type] or= new Dialog(type)
      @createdDialogs[type].open(event, args)

    closeDialog: (type) ->
      @createdDialogs[type] or= new Dialog(type)
      @createdDialogs[type].close()

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