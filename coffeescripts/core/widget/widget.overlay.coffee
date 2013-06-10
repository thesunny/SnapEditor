# This is an overlay for the widget. It adds the overlay to the top of the
# widget and is absolutely positioned to cover the widget.
#
# The iframe is used because it provides a better overlay than just a simple
# div. There were 2 problems with using the iframe.
# 1. The iframe needed to be transparent so the stuff underneath can be seen.
# 2. The iframe needed to be clickable to render the edit dialog.
# The following are the solutions and they work together to solve both (1) and
# (2).
# 1. The iframe contains an html, body, and a div overlay. Everything needs to
#    have 100% height in order for the overlay to have 100% height. If the
#    height is not 100%, there's nothing to click.
# 2. The allowtransparency attribute is required to make the iframe
#    transparent.
# 3. The div overlay is used because the transparency styles cannot be applied
#    to the body.
# 4. A background colour of white and opacity is used to fake transparency.
#
# The buttons are positioned absolutely on top of the iframe.
#
# There is a wrapper div around both the iframe and buttons to solve a
# previous problem. Before, there was no wrapper div and the mouse events were
# applied to the iframe. This caused a problem because the buttons were
# positioned at 0 top and 0 left. When the mouse left the widget through the
# top or left of the buttons, the mouseout event would not fire from the
# iframe because we moused out of the buttons, not the iframe. We could
# position the buttons at 1 top and 1 left, but the issue remained if the
# buttons' height was larger than the widget's height. Mousing out from the
# bottom of the button would cause the same problem. Hence, we use a wrapper
# div and put the mousein and mouseout events on that instead. This way, the
# events bubble up to the wrapper and it will always fire the events. The
# mouseup needs to remain on the iframe though because the mouseup occurs from
# the inside of the iframe and does not bubble up to the wrapper div.
#
# <div class="widget">
#   <div>
#     <iframe>
#       <!-- actual overlay -->
#     </iframe>
#     <div>
#       <!-- buttons -->
#     </div>
#   </div>
#   <p>Widget content</p>
# </div>
define ["jquery.custom", "core/widget/widget.object", "core/iframe"], ($, WidgetObject, IFrame) ->
  class WidgetOverlay
    constructor: (el, @classname, @api) ->
      @$el = $(el)
      @type = @$el.attr("data-type")
      @widget = SnapEditor.widgets[@type]
      throw "WidgetOverlay: widget type does not exist - #{@type}" unless @widget
      @widgetObject = new WidgetObject(@type, @classname, @api, WidgetOverlay)

    insert: ->
      @$el.css("position", "relative")
      size = @$el.getSize()

      @$overlay = $("<div/>").css(
        position: "absolute"
        top: 0
        left: 0
        zIndex: 100
        width: "100%"
        height: "100%"
      ).on(
        mouseover: @mouseover
        mouseout: @mouseout
      ).prependTo(@$el)

      self = this
      $(new IFrame(
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
          $(@find("body")).mouseup(self.mouseup)
      )).
      # The frameborder must be set before the iframe is inserted. If it is
      # added afterwards, it has no effect.
      attr("frameborder", 0).
      attr("allowtransparency", true).
      css(
        border: "none"
        width: "100%"
        height: "100%"
        cursor: "default"
      ).
      appendTo(@$overlay)

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
        appendTo(@$overlay)
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
        @api.selectElementContents(sibling)
        @api.collapse(true)
      else
        sibling = @$el.next()[0]
        @api.selectElementContents(sibling)
        @api.collapse(false)
      @edit(e) unless($(e.target).parent(".#{@classname}_buttons")[0])

    mouseover: (e) =>
      @$buttons.show()

    mouseout: (e) =>
      @$buttons.hide()

    edit: (e) =>
      @$buttons.hide()
      @widgetObject.load(@$el)
      # TODO: Include modified mouse coordinates.
      @widget.onEdit(
        api: @api
        widget: @widgetObject
        domEvent: e
      )

    remove: (e) =>
      @$buttons.hide()
      @widgetObject.load(@$el)
      # TODO: Include modified mouse coordinates.
      @widget.onRemove(
        api: @api
        widget: @widgetObject
        domEvent: e
      )
