# json2 is needed for IE7. IE7 does not implement JSON natively.
# NOTE: json2 does not follow AMD. The J is needed to swallow up the undefined
# given by json2.
define ["../../../lib/json2", "jquery.custom", "core/widget/widget.overlay"], (J, $, WidgetOverlay) ->
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
      @insertEl() unless @$el
      @$el.attr("data-type", @type)
      @$el.attr("data-json", JSON.stringify(@json))
      @$el.html(@html)
      @setWidget()
      @insertOverlay()
      @api.clean(@$el.parent()[0].firstChild, @$el.parent()[0].lastChild)

    remove: ->
      @$el.remove()

    teardown: ->
      @overlay.teardown()

    #
    # HELPERS
    #

    load: (el) ->
      @$el = $(el)
      @type = @$el.attr("data-type")
      @json = JSON.parse(@$el.attr("data-json"))
      @html = @$el.html()
      @setWidget()
      @insertOverlay()

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
