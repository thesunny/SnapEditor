define ["jquery.custom", "core/widget/widget.event", "core/widget/widget.overlay"], ($, WidgetEvent, WidgetOverlay) ->
  class WidgetsManager
    constructor: (@api, @classname) ->
      @api.on("snapeditor.activate", @activate)
      @api.on("snapeditor.deactivate", @deactivate)

    createWidget: (type, args = []) ->
      widget = SnapEditor.widgets[type]
      throw "createWidget(): widget type does not exist - #{type}" unless widget

      # Set the default onRemove function if it doesn't exist.
      widget.remove or= (e) -> e.remove()

      event = @createEvent(type)
      args.unshift(event)
      widget.create.apply(widget, args)

    createEvent: (type, el = null) ->
      widgetEvent = new WidgetEvent(type, @classname, @api, WidgetOverlay)
      widgetEvent.load(el) if el
      widgetEvent

    activate: =>
      @setup()
      @api.on("snapeditor.beforeGetContent", @teardown)
      @api.on("snapeditor.afterGetContent", @setup)

    deactivate: =>
      @teardown()
      @api.off("snapeditor.beforeGetContent", @teardown)
      @api.off("snapeditor.afterGetContent", @setup)

    setup: =>
      setupWidget = @setupWidget
      $(@api.find(".#{@classname}")).each(-> setupWidget(this))

    setupWidget: (el) =>
      (new WidgetOverlay(el, @classname, @api)).insert()

    teardown: =>
      teardownWidget = @teardownWidget
      $(@api.find(".#{@classname}")).each(-> teardownWidget(this))

    teardownWidget: (el) =>
      $(el).css("position", "")
      $(el).find("#{@classname}_overlay").remove()

  return WidgetsManager
