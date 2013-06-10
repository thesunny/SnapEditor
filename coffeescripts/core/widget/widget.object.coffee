# json2 is needed for IE7. IE7 does not implement JSON natively.
# NOTE: json2 does not follow AMD. The J is needed to swallow up the undefined
# given by json2.
define ["../../../lib/json2", "jquery.custom"], (J, $) ->
  class WidgetObject
    constructor: (@type, @classname, @api, @overlayClass) ->
      @json = {}
      @html = ""
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
      (new @overlayClass(@$el, @classname, @api)).insert()
      @api.clean(@$el.parent()[0].firstChild, @$el.parent()[0].lastChild)

    remove: ->
      @$el.remove()

    #
    # HELPERS
    #

    load: (el) ->
      @$el = $(el)
      @type = @$el.attr("data-type")
      @json = JSON.parse(@$el.attr("data-json"))
      @html = @$el.html()

    #
    # PRIVATE
    #

    insertEl: ->
      $el = $("<div/>").attr("id", "INSERT_WIDGET").addClass(@classname).attr("contenteditable", false)
      @range.delete()
      @range.insert($el[0])
      @$el = $(@api.find("#INSERT_WIDGET")).removeAttr("id")
