define ["jquery.custom", "core/data_action_handler"], ($, DataActionHandler) ->
  class ContextMenu
    constructor: (@api, @config) ->
      @$el = $(@api.el)
      @contexts = []
      @contexts.push(context) for context, button of @config
      @buttonGroups = {}
      @api.on("activate.editor", @activate)
      @api.on("deactivate.editor", @deactivate)

    activate: =>
      @$el.on("contextmenu", @show)

    deactivate: =>
      @$el.off("contextmenu", @show)
      @hide()

    show: (e) =>
      e.preventDefault()
      @buildMenu(e.target)
      @$menu.css(@getStyles(e.pageX, e.pageY)).show()
      $(document).on("click", @tryHide)
      $(document).on("keydown", @hide)

    hide: =>
      @$menu.hide() if @$menu
      $(document).off("click", @tryHide)
      $(document).off("keydown", @hide)

    # Hide if the target is not the contextmenu.
    tryHide: (e) =>
      $target = $(e.target)
      @hide() unless $target.attr("id") == @id or $target.parent("##{@id}").length > 0

    # Build the menu based on the current context.
    buildMenu: (target) ->
      $target = $(target)
      unless @$menu
        @id = "snapeditor_contextmenu_#{Math.floor(Math.random() * 99999)}"
        @$menu = $("<div id=\"#{@id}\" class=\"contextmenu\">").css("position", "absolute").hide().appendTo("body")
        new DataActionHandler(@$menu, @api)
      @$menu.empty()
      matchedContexts = $target.contexts(@contexts, @$el)
      @$menu.append(@getButtonGroup("default"))
      @$menu.append(@getButtonGroup(context)) for context, el of matchedContexts

    # Grab the buttons for the given context.
    getButtonGroup: (context) ->
      return @buttonGroups[context] if @buttonGroups[context]
      unless @config[context]
        return null if context == "default"
        throw "Missing contextmenu buttons for context '#{context}'"
      $buttons = $('<div class="snapeditor_contextmenu_item_group">')
      $buttons.append($(button.htmlForContextMenu())) for button in @config[context]
      @buttonGroups[context] = $buttons

    getMenuCoords: ->
      # Uses measure in case the menu is not visible.
      @menuCoords or= @$menu.measure(-> @getCoordinates())

    # Get the styles needed to display the contextmenu where the cursor is but
    # always stay within the viewable window.
    getStyles: (x, y) ->
      styles = top: y, left: x
      windowScroll = $(window).getScroll()
      windowSize = $(window).getSize()
      windowBottom = windowScroll.y + windowSize.y
      windowRight = windowScroll.x + windowSize.x
      menuHeight = @getMenuCoords().height
      menuWidth = @getMenuCoords().width
      # If the menu doesn't fit vertically.
      if styles.top + menuHeight > windowBottom
        styles.top = windowBottom - menuHeight
      # If the menu doesn't fit horizontally.
      if styles.left + menuWidth > windowRight
        styles.left = windowRight - menuWidth
      styles

  return ContextMenu
