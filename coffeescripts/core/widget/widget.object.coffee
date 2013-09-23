# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
# json2 is needed for IE7. IE7 does not implement JSON natively.
# NOTE: json2 does not follow AMD. The J is needed to swallow up the undefined
# given by json2.
define ["../../../lib/json2", "jquery.custom", "core/browser", "core/widget/widget.overlay"], (J, $, Browser, WidgetOverlay) ->
  class WidgetObject
    # Options:
    # type
    # el
    # Either type or el must be specified.
    constructor: (@api, @classname, @options = {}) ->
      @json = {}
      @html = ""
      if @options.type
        @type = @options.type
        @setWidget()
      @load(@options.el) if @options.el
      # Save the range.
      @range = @api.getRange()

    #
    # PUBLIC
    #

    getEl: ->
      @$el && @$el[0]

    save: ->
      # In Webkit and Firefox, we have to manually move the focus back to the
      # editor.
      # The focus is set before inserting because in Webkit, if we focus
      # afterwards, the focus is set, but not really. The cursor shows, but
      # you have to hit a key before focus is actually set. If we focus before
      # we insert, the insertion acts as the focus trigger. Firefox works no
      # matter where you put the focus.
      # @api.win.focus() must be used in Webkit because @api.el.focus() makes
      # the page jump.
      # @api.el.focus() must be used in Firefox because @api.win.focus() does
      # nothing.
      # This affects IE as it makes the page jump to where the cursor is.
      @api.win.focus() if Browser.isWebkit
      @api.el.focus() if Browser.isGecko
      @insertEl() unless @$el
      @$el.attr("data-type", @type)
      @$el.attr("data-json", JSON.stringify(@json))
      @$el.html(@html)
      @setWidget()
      @insertOverlay()
      @api.clean(@$el.parent()[0].firstChild, @$el.parent()[0].lastChild)

    remove: ->
      @$el.remove()

    #
    # HELPERS
    #

    # Calls the #onCreate function of the widget.
    onCreate: (e, args = []) ->
      # Create a new event off the given event.
      event = $.extend(
        api: @api
        widget: this
        e
      )
      args.unshift(event)
      @widget.onCreate.apply(@widget, args)

    onEdit: (e) ->
      @widget.onEdit(
        api: @api
        widget: this
        domEvent: e
      )

    onRemove: (e) ->
      if @widget.onRemove
        @widget.onRemove(
          api: @api
          widget: this
          domEvent: e
        )
      else
        @remove()

    # Loads widget object data from the given el.
    load: (el) ->
      @$el = $(el)
      @type = @$el.attr("data-type")
      @json = JSON.parse(@$el.attr("data-json"))
      @html = @$el.html()
      @setWidget()
      @insertOverlay()

    # Tears down the widget object.
    teardown: ->
      @overlay.teardown() if @overlay

    #
    # PRIVATE
    #

    setWidget: ->
      @widget = SnapEditor.widgets[@type]
      throw "Widget type does not exist - #{@type}" unless @widget

    insertEl: ->
      $el = $(@api.createElement("div")).attr("id", "INSERT_WIDGET").addClass(@classname).attr("contenteditable", false)
      @range.delete()
      @range.insert($el[0])
      @$el = $(@api.find("#INSERT_WIDGET")).removeAttr("id")

    insertOverlay: ->
      @overlay or= new WidgetOverlay(this)
      @overlay.insert()
