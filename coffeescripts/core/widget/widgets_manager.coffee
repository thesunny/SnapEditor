define ["jquery.custom", "core/widget/widget.object", "core/widget/widget.overlay"], ($, WidgetObject, WidgetOverlay) ->
  class WidgetsManager
    constructor: (@api, @classname) ->
      @api.on("snapeditor.activate", @activate)
      @api.on("snapeditor.deactivate", @deactivate)

    insertWidget: (type, args = []) ->
      widget = SnapEditor.widgets[type]
      throw "insertWidget(): widget type does not exist - #{type}" unless widget

      # Set the default onRemove function if it doesn't exist.
      widget.onRemove or= (e) -> e.widget.remove()

      widgetObject = @createWidgetObject(type)
      event =
        api: @api
        widget: widgetObject
      args.unshift(event)
      widget.onCreate.apply(widget, args)

    createWidgetObject: (type, el = null) ->
      widgetObject = new WidgetObject(type, @classname, @api, WidgetOverlay)
      widgetObject.load(el) if el
      widgetObject

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
