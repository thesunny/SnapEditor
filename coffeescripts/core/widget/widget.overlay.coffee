define ["jquery.custom", "core/widget/widget.event", "core/iframe"], ($, WidgetEvent, IFrame) ->
  class WidgetOverlay
    constructor: (el, @classname, @api) ->
      @$el = $(el)
      @type = @$el.attr("data-type")
      @widget = SnapEditor.widgets[@type]
      throw "WidgetOverlay: widget type does not exist - #{@type}" unless @widget
      @widgetEvent = new WidgetEvent(@type, @classname, @api, WidgetOverlay)

    insert: ->
      @$el.css("position", "relative")
      size = @$el.getSize()
      self = this
      @overlay = new IFrame(
        write: ->
          @doc.write("""
            <!DOCTYPE html>
            <html style="height: 100%;">
              <head>
                <style>
                  body, .overlay {
                    width: 100%;
                    height: 100%;
                    padding: 0;
                    margin: 0;
                  }
                  .overlay {
                    position: absolute;
                    top: 0;
                    left: 0;
                    z-index: -1;
                    background-color: white;
                    -ms-filter: "progid:DXImageTransform.Microsoft.Alpha(Opacity=10)";
                    filter: alpha(opacity=10);
                    opacity: 0.1;
                  }
                </style>
              </head>
              <body class="snapeditor_ignore_deactivate"><div class="overlay"></div></body>
            </html>
          """)
        load: ->
          $(@find("body")).on(
            mouseup: self.mouseup
            mouseover: self.mouseover
            mouseout: self.mouseout
          )
      )
      # The frameborder must be set before the iframe is inserted. If it is
      # added afterwards, it has no effect.
      $(@overlay).
        attr("frameborder", 0).
        attr("allowtransparency", true).
        css(
          border: "none"
          position: "absolute"
          top: 0
          left: 0
          zIndex: 100
          width: "100%"
          height: "100%"
          cursor: "default"
        ).
        prependTo(@$el)

      @$buttons = $("<div/>").
        addClass("#{@classname}_buttons").
        css(
          position: "absolute"
          top: 0
          left: 0
          zIndex: 101
          cursor: "default"
        ).
        hide().
        insertAfter(@overlay)
      @$edit = $("<button/>").
        addClass("#{@classname}_edit").
        html("edit").
        click(@edit).
        appendTo(@$buttons)
      @$remove = $("<button/>").
        addClass("#{@classname}_remove").
        html("remove").
        click(@remove).
        appendTo(@$buttons)

    mouseup: (e) =>
      sibling = @$el.prev()[0]
      if sibling
        @api.selectNodeContents(sibling)
        @api.collapse(true)
      else
        sibling = @$el.next()[0]
        @api.selectNodeContents(sibling)
        @api.collapse(false)
      @edit(e) unless($(e.target).parent(".#{@classname}_buttons")[0])

    mouseover: (e) =>
      @$buttons.show()

    mouseout: (e) =>
      @$buttons.hide()

    edit: (e) =>
      @$buttons.hide()
      @widgetEvent.load(@$el)
      # TODO: Include modified mouse coordinates.
      @widgetEvent.domEvent = e
      @widget.edit(@widgetEvent)

    remove: (e) =>
      @$buttons.hide()
      @widgetEvent.load(@$el)
      @widgetEvent.domEvent = e
      @widget.remove(@widgetEvent)
