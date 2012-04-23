define ["jquery.custom"], ($) ->
  class ContextManager
    ###
      Editor.ContextManager takes callbacks corresponding to when certain
      contexts have been entered.

        * showBlock
        * hideBlock
        * showTable
        * hideTable
        * showList
        * hideList
        * showImage
        * hideImage

      Originally each toolbar handled its own show/hide logic but this method
      was implemented because it reduced processing overhead. Instead of doing
      a full range check for each toolbar to see if the toolbar is valid, we
      instead do a single check for all toolbars.
    ###

    #include(ContextManager, Events)
    # showBlock, hideBlock,
    # showTable, hideTable,
    # showList, hideList,
    # showImage, hideImage, selectImage

    constructor: ->
      @mode = '' # mode can be block, list, table or image (list not implemented yet)
      @tableTags = [ 'td', 'th', 'table' ]
      @listTags = [ 'ul', 'ol', 'li' ]

    register: (@api) ->
      @$el = $(@api.el)
      @api.on("activate.editor", @activate)
      @api.on("deactivate.editor", @deactivate)

    activate: =>
      @$el.on("keyup", @onkeyup)
      @$el.on("mouseup", @onmouseup)

    deactivate: =>
      @$el.off("keyup", @onkeyup)
      @$el.off("mouseup", @onmouseup)

    # This expects some sort of a mouse event and should be called when the
    # editor has finished loading and is ready. The most important thing that
    # must be ready is that the range must exist at this point.
    #onReady: (e) ->
      #@onmouseup(e)

    onkeyup: (e) =>
      # key code 13 is 'ENTER'
      # key code 33 to 40 are all navigation keys
      @updateByRange() if e.which == 13 or 33 <= e.which <= 40

    onmouseup: (e) =>
      @updateByRange()

    updateByRange: =>
      range = new Editor.Range(@el, window)
      el = range.getParentElement(@matchElement)
      unless el
        @updateMode('block', el)
        return
      tag = $(el).tagName()
      if $.inArray(tag, @tableTags) != -1
        @updateMode('table', el)
      else if $.inArray(tag, @listTags) != -1
        @updateMode('list', el)
      else
        @updateMode('block', el)

    matchElement: (el) =>
      @matchTags or= @tableTags.concat(@listTags)
      $.inArray($(el).tagName(), @matchTags) != -1

    isImage: (el) ->
      el and $(el).tagName() == 'img'

    updateMode: (mode, target) =>
      modeTarget = @getModeTarget(target)
      unless @modeTarget == modeTarget
        @triggerHandler('hide' + capitalize(@mode), target)
        @triggerHandler('show' + capitalize(mode), target)
        @modeTarget = modeTarget
        @mode = mode
      @triggerHandler('selectImage', target) if @isImage(target)

    getModeTarget: (target) ->
      modeTarget = null
      if target
        if @isImage(target)
          modeTarget = target
        else if $.inArray($(target).tagName(), @tableTags) != -1
          if $(target).tagName() == 'table'
            modeTarget = target
          else
            modeTarget = $(target).parent('table')
      modeTarget

  return ContextManager
