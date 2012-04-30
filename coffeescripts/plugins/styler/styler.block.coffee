define ["jquery.custom", "core/browser", "core/helpers"], ($, Browser, Helpers) ->
  class BlockStyler
    register: (@api) ->

    getUI: (ui) ->
      p = ui.button(action: "p", title: "Paragraph (Ctrl+Space)", icon: "image.png")
      h1 = ui.button(action: "h1", title: "H1 (Ctrl+1)", icon: "image.png")
      h2 = ui.button(action: "h2", title: "H2 (Ctrl+2)", icon: "image.png")
      h3 = ui.button(action: "h3", title: "H3 (Ctrl+3)", icon: "image.png")
      alignLeft = ui.button(action: "alignleft", title: "Align Left (Ctrl+L)", icon: "image.png")
      alignCenter = ui.button(action: "aligncenter", title: "Align Center (Ctrl+E)", icon: "image.png")
      alignRight = ui.button(action: "alignright", title: "Align Right (Ctrl+R)", icon: "image.png")
      unorderedList = ui.button(action: "unorderedlist", title: "Bullet List (Ctrl+8)", icon: "image.png")
      orderedList = ui.button(action: "orderedlist", title: "Numbered List (Ctrl+7)", icon: "image.png")
      indent = ui.button(action: "indent", title: "Indent", icon: "image.png")
      outdent = ui.button(action: "outdent", title: "Outdent", icon: "image.png")
      return {
        "toolbar:default": "block"
        block: [p, h1, h2, h3, alignLeft, alignCenter, alignRight, unorderedList, orderedList, indent, outdent]
        p: p
        h1: h1
        h2: h2
        h3: h3
        alignLeft: alignLeft
        alignCenter: alignCenter
        alignRight: alignRight
        unorderedList: unorderedList
        orderedList: orderedList
        indent: indent
        outdent: outdent
      }

    getActions: ->
      return {
        p: @p
        h1: @h1
        h2: @h2
        h3: @h3
        alignleft: @alignLeft
        aligncenter: @alignCenter
        alignright: @alignRight
        unorderedlist: @unorderedList
        orderedlist: @orderedList
        indent: @indent
        outdent: @outdent
      }

    getKeyboardShortcuts: ->
      return {
        "ctrl.space": @p
        "ctrl.1": @h1
        "ctrl.2": @h2
        "ctrl.3": @h3
        "ctrl.l": @alignLeft
        "ctrl.e": @alignCenter
        "ctrl.r": @alignRight
        "ctrl.8": @unorderedList
        "ctrl.7": @orderedList
      }

    p: =>
      @formatBlock('p')
      @update()

    h1: =>
      @formatBlock('h1')
      @update()

    h2: =>
      @formatBlock('h2')
      @update()

    h3: =>
      @formatBlock('h3')
      @update()

    formatBlock: (tag) =>
      # TODO-SH:
      # In Chrome, formatting a block with a p tag removes any span formatting
      # like bold and italic. May have to create a special version just for
      # webkit (Chrome and Safari).

      # ie required the angled brackets around the tag or it fails
      @exec("formatblock", "<#{tag}>")
      @update()

    alignLeft: =>
      @align("left")

    alignCenter: =>
      @align("center")

    alignRight: =>
      @align("right")

    # position can be left, center, right.
    align: (position) ->
      command = "justify#{Helpers.capitalize(position)}"
      try
        @exec(command)
      catch e
        # Bug #2027: Cannot align first line of text in FF
        # This is a bug in Mozilla FireFox itself.
        # Copied the patch from comment #8 and modified it.
        # https:#bugzilla.mozilla.org/show_bug.cgi?id=442186#c8
        # The basic idea is to insert a dummy element before the first element.
        # This way, we're not aligning the first element and the bug doesn't
        # show up. After alignment, the dummy element is removed.
        # TODO-WW: When the bug is finally fixed, we can remove the whole entire
        # try/catch block.

        #special case for Mozilla Bug #442186
        if e and e.result == 2147500037
          #probably firefox bug 442186 - workaround
          range = window.getSelection().getRangeAt(0)
          dummy = document.createElement('span')

          # Wesley: Commented out the search for the contentEditable element
          # since we already have it (@el).
          #find node with contentEditable
          #ceNode = range.startContainer.parentNode
          #while (ceNode && ceNode.contentEditable != 'true') ->
            #ceNode = ceNode.parentNode
          #}
          #if !ceNode throw 'Selected node is not editable!' }
          ceNode = @el

          ceNode.insertBefore(dummy, ceNode.childNodes[0])
          @exec(command)
          dummy.parentNode.removeChild(dummy)
        else if console and console.log
          console.log(e)
      @update()

    unorderedList: =>
      @exec("insertunorderedlist")
      @update()

    orderedList: =>
      @exec("insertorderedlist")
      @update()

    indent: =>
      @exec("indent")
      @update()

    outdent: =>
      @exec("outdent")
      @update()

    exec: (cmd, value = null) ->
      document.execCommand(cmd, false, value)

    update: ->
      # In Firefox, when a user clicks on the toolbar to style, the
      # editor loses focus. Instead, the focus is set on the toolbar
      # button (even though unselectable="on"). Whenever the user
      # types a character, it inserts it into the editor, but also
      # presses the toolbar button. This can result in alternating
      # behaviour. For example, if I click on the list button. When
      # I start typing, it will toggle lists on and off.
      # This cannot be called for IE because it will cause the window to scroll
      # and jump. Hence this is only for Firefox.
      @api.el.focus() if Browser.isMozilla
      @api.update()

  return BlockStyler
