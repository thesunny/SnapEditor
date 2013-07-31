define ["jquery.custom", "core/widget/widget.object"], ($, WidgetObject) ->
  class WidgetsManager
    constructor: (@editor, @classname) ->
      @editor.on("snapeditor.activate", @activate)
      @editor.on("snapeditor.deactivate", @deactivate)

    # The first argument is the type.
    # All other arguments are extra arguments to be passed to the onCreate().
    insertWidget: ->
      type = arguments[0]
      args = [].slice.apply(arguments, [1])
      widget = SnapEditor.widgets[type]
      throw "insertWidget(): widget type does not exist - #{type}" unless widget

      # Set the default onRemove function if it doesn't exist.
      widget.onRemove or= (e) -> e.widget.remove()

      # If an event was passed through the arguments, "clone" it and add the
      # widget attribute.
      # If no event was passed through, create a new event with the api and
      # widget attribute.
      event = $.extend(
        api: @editor.api
        widget: @createWidgetObject(type: type)
        args.shift()
      )
      args.unshift(event)
      widget.onCreate.apply(widget, args)

    # Options:
    # type
    # el
    # Either type or el must be specified.
    createWidgetObject: (options = {}) ->
      new WidgetObject(@editor.api, @classname, options)

    activate: =>
      @setup()
      @editor.on("snapeditor.beforeGetContent", @teardown)
      @editor.on("snapeditor.afterGetContent", @setup)

    deactivate: =>
      @teardown()
      @editor.off("snapeditor.beforeGetContent", @teardown)
      @editor.off("snapeditor.afterGetContent", @setup)

    setup: =>
      createWidgetObject = @createWidgetObject
      $(@editor.find(".#{@classname}")).each(-> createWidgetObject(el: this))

    teardown: =>
      teardownWidget = @teardownWidget
      $(@editor.find(".#{@classname}")).each(-> teardownWidget(this))

    teardownWidget: (el) =>
      $(el).css("position", "")
      $(el).find("#{@classname}_overlay").remove()
