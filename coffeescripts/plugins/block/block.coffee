define ["jquery.custom", "core/browser", "core/helpers"], ($, Browser, Helpers) ->
  class Block
    register: (@api) ->

    getUI: (ui) ->
      p = ui.button(action: "p", description: @api.lang.paragraph, shortcut: "Ctrl+Alt+0", icon: { url: @api.assets.image("p.png"), width: 24, height: 24, offset: [3, 3] })
      h1 = ui.button(action: "h1", description: @api.lang.h1, shortcut: "Ctrl+Alt+1", icon: { url: @api.assets.image("text_heading_1.png"), width: 24, height: 24, offset: [3, 3] })
      h2 = ui.button(action: "h2", description: @api.lang.h2, shortcut: "Ctrl+Alt+2", icon: { url: @api.assets.image("text_heading_2.png"), width: 24, height: 24, offset: [3, 3] })
      h3 = ui.button(action: "h3", description: @api.lang.h3, shortcut: "Ctrl+Alt+3", icon: { url: @api.assets.image("text_heading_3.png"), width: 24, height: 24, offset: [3, 3] })
      h4 = ui.button(action: "h4", description: @api.lang.h4, shortcut: "Ctrl+Alt+4", icon: { url: @api.assets.image("text_heading_4.png"), width: 24, height: 24, offset: [3, 3] })
      h5 = ui.button(action: "h5", description: @api.lang.h5, shortcut: "Ctrl+Alt+5", icon: { url: @api.assets.image("text_heading_5.png"), width: 24, height: 24, offset: [3, 3] })
      h6 = ui.button(action: "h6", description: @api.lang.h6, shortcut: "Ctrl+Alt+6", icon: { url: @api.assets.image("text_heading_6.png"), width: 24, height: 24, offset: [3, 3] })
      #alignLeft = ui.button(action: "alignLeft", description: "Align Left", shortcut: "Ctrl+L", icon: { url: @api.assets.image("toolbar.png"), width: 24, height: 24, offset: [3, 3] })
      #alignCenter = ui.button(action: "alignCenter", description: "Align Center", shortcut: "Ctrl+E", icon: { url: @api.assets.image("toolbar.png"), width: 24, height: 24, offset: [3, 3] })
      #alignRight = ui.button(action: "alignRight", description: "Align Right", shortcut: "Ctrl+R", icon: { url: @api.assets.image("toolbar.png"), width: 24, height: 24, offset: [3, 3] })
      return {
        "toolbar:default": "block"
        block: [p, h1, h2, h3]
        p: p
        h1: h1
        h2: h2
        h3: h3
        h4: h4
        h5: h5
        h6: h6
        #alignLeft: alignLeft
        #alignCenter: alignCenter
        #alignRight: alignRight
      }

    getActions: ->
      return {
        p: @p
        h1: @h1
        h2: @h2
        h3: @h3
        h4: @h4
        h5: @h5
        h6: @h6
        #alignLeft: @alignLeft
        #alignCenter: @alignCenter
        #alignRight: @alignRight
      }

    getKeyboardShortcuts: ->
      return {
        "ctrl.alt.0": "p"
        "ctrl.alt.1": "h1"
        "ctrl.alt.2": "h2"
        "ctrl.alt.3": "h3"
        "ctrl.alt.4": "h4"
        "ctrl.alt.5": "h5"
        "ctrl.alt.6": "h6"
        #"ctrl.l": "alignLeft"
        #"ctrl.e": "alignCenter"
        #"ctrl.r": "alignRight"
      }

    p: =>
      @update() if @api.formatBlock('p')

    h1: =>
      @update() if @api.formatBlock('h1')

    h2: =>
      @update() if @api.formatBlock('h2')

    h3: =>
      @update() if @api.formatBlock('h3')

    h4: =>
      @update() if @api.formatBlock('h4')

    h5: =>
      @update() if @api.formatBlock('h5')

    h6: =>
      @update() if @api.formatBlock('h6')

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

    update: ->
      # In Webkit, after the toolbar is clicked, the focus hops to the parent
      # window. We need to refocus it back into the iframe. Focusing breaks IE
      # and kills the range so the focus is only for Webkit. It does not affect
      # Firefox.
      @api.win.focus() if Browser.isWebkit
      @api.clean()

  return Block
