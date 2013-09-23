# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom", "core/widget/widget.object"], ($, WidgetObject) ->
  class WidgetsManager
    constructor: (@editor, @classname) ->
      @widgetObjects = []
      @editor.on("snapeditor.activate", @activate)
      @editor.on("snapeditor.deactivate", @deactivate)

    # The first argument is the type.
    # All other arguments are extra arguments to be passed to the onCreate().
    # It is expected that first argument of the other arguments is SnapEditor
    # event object.
    insertWidget: ->
      type = arguments[0]
      event = arguments[1]
      args = [].slice.apply(arguments, [2])
      @createWidgetObject(type: type).onCreate(event, args)

    # Options:
    # type
    # el
    # Either type or el must be specified.
    createWidgetObject: (options = {}) ->
      widgetObject = new WidgetObject(@editor.api, @classname, options)
      @widgetObjects.push(widgetObject)
      widgetObject

    activate: =>
      @setup()
      @editor.on("snapeditor.beforeGetContent", @teardown)
      @editor.on("snapeditor.afterGetContent", @setup)

    deactivate: =>
      @teardown()
      @editor.off("snapeditor.beforeGetContent", @teardown)
      @editor.off("snapeditor.afterGetContent", @setup)

    setup: =>
      self = this
      $(@editor.find(".#{@classname}")).each(-> self.createWidgetObject(el: this))

    teardown: =>
      widgetObject.teardown() for widgetObject in @widgetObjects
      @widgetObjects = []
