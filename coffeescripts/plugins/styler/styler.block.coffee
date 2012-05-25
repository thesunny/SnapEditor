define ["jquery.custom", "core/browser", "core/helpers"], ($, Browser, Helpers) ->
  class BlockStyler
    register: (@api) ->

    getUI: (ui) ->
      p = ui.button(action: "p", description: "Paragraph", shortcut: "Ctrl+0", icon: { url: @api.assets.image("toolbar.png"), width: 31, height: 24, offset: [0, -53] })
      h1 = ui.button(action: "h1", description: "H1", shortcut: "Ctrl+1", icon: { url: @api.assets.image("toolbar.png"), width: 30, height: 24, offset: [-31, -53] })
      h2 = ui.button(action: "h2", description: "H2", shortcut: "Ctrl+2", icon: { url: @api.assets.image("toolbar.png"), width: 30, height: 24, offset: [-61, -53] })
      h3 = ui.button(action: "h3", description: "H3", shortcut: "Ctrl+3", icon: { url: @api.assets.image("toolbar.png"), width: 30, height: 24, offset: [-91, -53] })
      #alignLeft = ui.button(action: "alignLeft", description: "Align Left", shortcut: "Ctrl+L", icon: { url: @api.assets.image("toolbar.png"), width: 31, height: 24, offset: [0, -149] })
      #alignCenter = ui.button(action: "alignCenter", description: "Align Center", shortcut: "Ctrl+E", icon: { url: @api.assets.image("toolbar.png"), width: 30, height: 24, offset: [-31, -149] })
      #alignRight = ui.button(action: "alignRight", description: "Align Right", shortcut: "Ctrl+R", icon: { url: @api.assets.image("toolbar.png"), width: 30, height: 24, offset: [-61, -149] })
      unorderedList = ui.button(action: "unorderedList", description: "Bullet List", shortcut: "Ctrl+8", icon: { url: @api.assets.image("toolbar.png"), width: 31, height: 24, offset: [0, -125] })
      orderedList = ui.button(action: "orderedList", description: "Numbered List", shortcut: "Ctrl+7", icon: { url: @api.assets.image("toolbar.png"), width: 30, height: 24, offset: [-31, -125] })
      indent = ui.button(action: "indent", description: "Indent", icon: { url: @api.assets.image("toolbar.png"), width: 30, height: 24, offset: [-61, -125] })
      outdent = ui.button(action: "outdent", description: "Outdent", icon: { url: @api.assets.image("toolbar.png"), width: 30, height: 24, offset: [-91, -125] })
      return {
        "toolbar:default": "block"
        block: [p, h1, h2, h3, unorderedList, orderedList, indent, outdent]
        p: p
        h1: h1
        h2: h2
        h3: h3
        #alignLeft: alignLeft
        #alignCenter: alignCenter
        #alignRight: alignRight
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
        #alignLeft: @alignLeft
        #alignCenter: @alignCenter
        #alignRight: @alignRight
        unorderedList: @unorderedList
        orderedList: @orderedList
        indent: @indent
        outdent: @outdent
      }

    getKeyboardShortcuts: ->
      return {
        "ctrl.0": "p"
        "ctrl.1": "h1"
        "ctrl.2": "h2"
        "ctrl.3": "h3"
        #"ctrl.l": "alignLeft"
        #"ctrl.e": "alignCenter"
        #"ctrl.r": "alignRight"
        "ctrl.8": "unorderedList"
        "ctrl.7": "orderedList"
      }

    p: =>
      if @allowFormatBlock()
        @formatBlock('p')
        @update()

    h1: =>
      if @allowFormatBlock()
        @formatBlock('h1')
        @update()

    h2: =>
      if @allowFormatBlock()
        @formatBlock('h2')
        @update()

    h3: =>
      if @allowFormatBlock()
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

    #alignLeft: =>
      #@align("left")

    #alignCenter: =>
      #@align("center")

    #alignRight: =>
      #@align("right")

    ## position can be left, center, right.
    #align: (position) ->
      #command = "justify#{Helpers.capitalize(position)}"
      #try
        #@exec(command)
      #catch e
        ## Bug #2027: Cannot align first line of text in FF
        ## This is a bug in Mozilla FireFox itself.
        ## Copied the patch from comment #8 and modified it.
        ## https:#bugzilla.mozilla.org/show_bug.cgi?id=442186#c8
        ## The basic idea is to insert a dummy element before the first element.
        ## This way, we're not aligning the first element and the bug doesn't
        ## show up. After alignment, the dummy element is removed.
        ## TODO-WW: When the bug is finally fixed, we can remove the whole entire
        ## try/catch block.

        ##special case for Mozilla Bug #442186
        #if e and e.result == 2147500037
          ##probably firefox bug 442186 - workaround
          #range = window.getSelection().getRangeAt(0)
          #dummy = document.createElement('span')

          ## Wesley: Commented out the search for the contentEditable element
          ## since we already have it (@el).
          ##find node with contentEditable
          ##ceNode = range.startContainer.parentNode
          ##while (ceNode && ceNode.contentEditable != 'true') ->
            ##ceNode = ceNode.parentNode
          ##}
          ##if !ceNode throw 'Selected node is not editable!' }
          #ceNode = @el

          #ceNode.insertBefore(dummy, ceNode.childNodes[0])
          #@exec(command)
          #dummy.parentNode.removeChild(dummy)
        #else if console and console.log
          #console.log(e)
      #@update()

    unorderedList: =>
      if @allowList()
        @exec("insertunorderedlist")
        @update()

    orderedList: =>
      if @allowList()
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
      @api.clean()
      @api.update()

    allowFormatBlock: ->
      allowed = !@api.getParentElement("table, li")
      alert("Sorry. This action cannot be performed inside a table or list.") unless allowed
      return allowed

    allowList: ->
      allowed = !@api.getParentElement("table")
      alert("Sorry. This action cannot be performed inside a table.") unless allowed
      return allowed

  return BlockStyler
