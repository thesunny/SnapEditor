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

    # During activation we create all the widgetObjects for each widget in the
    # contentEditable. We also make sure that when the editors gets the content
    # that we teardown each of the widget objets which also removes the
    # DOM elements that we add in to make the widgets work. We then setup the
    # widgetObjects again after the content has been gotten.
    activate: =>
      @setup()
      @editor.on("snapeditor.beforeGetContent", @teardown)
      @editor.on("snapeditor.afterGetContent", @setup)

    # Basically does the reverse of activeate. Read that one.
    deactivate: =>
      @teardown()
      @editor.off("snapeditor.beforeGetContent", @teardown)
      @editor.off("snapeditor.afterGetContent", @setup)

    # creates all the widget objects. Note that each time this is called,
    # all the widget objects are created again even if they were previously
    # created.
    setup: =>
      self = this
      $(@editor.find(".#{@classname}")).each(-> self.createWidgetObject(el: this))

    # calls teardown on each of the widget objects and also empties the
    # @widgetObjects array. Effectively this destroys all the widgetObjects
    # as we do not reuse them.
    teardown: =>
      widgetObject.teardown() for widgetObject in @widgetObjects
      @widgetObjects = []
