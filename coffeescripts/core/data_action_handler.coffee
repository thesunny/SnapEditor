# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
# This is used to trigger events from button clicks and select or text input
# changes. It looks for a "data-action" attribute on the target and triggers
# that event. This makes it so that there is little wiring code needed and it
# is easy to change the events and the HTML.
define ["jquery.custom", "core/helpers", "core/browser"], ($, Helpers, Browser) ->
  class DataActionHandler
    # $el is the container element.
    # api is the editor API object.
    #
    # Options:
    # * mouseover: Triggers the action on mouseover if the target has
    #     data-mouseover set to true. The default is false.
    constructor: (el, @api, @options = {}) ->
      @$el = $(el)
      @api.on("snapeditor.activate", @activate)
      @api.on("snapeditor.deactivate", @deactivate)

    activate: =>
      # Listen to any change events on <select>.
      # NOTE: Unfortunately, IE does not bubble onchange events, even though
      # the standard says it should. Surprise. The workaround is to look for
      # and listen to the selects directly.
      @$el.children("select[data-action]").on("change", @change)
      # Mousedown is tracked because we want to handle the click only if it
      # started and ended within the el.
      @$el.on("mousedown", @setClick)
      # Uses a mouseup event instead of a mousedown because certain buttons
      # can unsnap the editor. If it was mousedown, the editor would finish
      # unsnapping and turn on the mouseup event. The mouseup event would
      # trigger and resnap the editor. A click is not used because in IE,
      # when an image is selected, resize image handlers show up. If the
      # el is on top of these handlers, the click event does not trigger. The
      # mousedown and mouseup events still trigger though.
      @$el.on("mouseup", @mouseup)
      # Listen to any keypresses.
      @$el.on("keypress", @change)
      # Listen to any mouseovers.
      @$el.on("mouseover", @mouseover)
      # In IE, the link causes the window's onbeforeunload to trigger, even if
      # the link isn't actually doing anything. In order to prevent this,
      # false is returned on the click to prevent the default behaviour.
      @$el.on("click", -> false) if Browser.isIE

    deactivate: =>
      @$el.children("select[data-action]").off("change", @change)
      @$el.off("mousedown", @setClick)
      @$el.off("mouseup", @mouseup)
      @$el.off("keypress", @change)

    setClick: (e) =>
      @isClick = true

    # Gets the closest element with a data-action attribute.
    getDataActionEl: (target) ->
       $(target).closest("[data-action]:not(select)")

    # The action should be triggered if it was a left click originating from
    # the el and comes from an element that has a data-action attribute.
    shouldTrigger: (e) ->
      # NOTE: IE7/8 report 0 for e.which when the mouse event is "click". All
      # others report the correct mouse button.
      @isClick and
        (e.which == 0 or e.which == Helpers.buttons.left) and
        @getDataActionEl(e.target).length > 0

    # When anything is clicked in the el, except a <select> which is handled by
    # the change function, it looks for a "data-action" attribute on the element
    # or its ancestors and uses that to trigger the event. The target is passed
    # along through the event.
    mouseup: (e) =>
      if @shouldTrigger(e)
        # In Firefox, when a user clicks on the toolbar to style, the
        # editor loses focus. Instead, the focus is set on the toolbar
        # button (even though unselectable="on"). Whenever the user
        # types a character, it inserts it into the editor, but also
        # presses the toolbar button. This can result in alternating
        # behaviour. For example, if I click on the list button. When
        # I start typing, it will toggle lists on and off.
        # This cannot be called for IE because it will cause the window to
        # scroll and jump. Hence this is only for Firefox.
        # @api.win.focus() must be used in Firefox when using an iframe
        # because @api.el.focus() makes the iframe jump.
        # @api.el.focus() must be used in Firefox when not using an iframe
        # because @api.win.focus() does nothing.
        # TODO: The call to @api.editor.iframe is really ugly. Figure out how
        # to fix this properly.
        if Browser.isGecko
          if @api.editor.iframe
            @api.win.focus()
          else
            @api.el.focus()
        action = @getDataActionEl(e.target).attr("data-action")
        @api.trigger(action, e.target)
      @isClick = false
      # Purposely added true here because the line above sets @isClick to false.
      # Since CoffeeScript returns the last statement, if the line above was the
      # last statement of this function, it would return false. However,
      # returning false from an event handler stops propagation. This is not
      # what we want. Hence, the true below.
      return true

    mouseover: (e) =>
      $action = @getDataActionEl(e.target)
      @api.trigger($action.attr("data-action"), e.target) if $action.length > 0 and $action.attr("data-mouseover") == "true"

    # When a select is changed or a keypress occurs in the el, it triggers the
    # event specified by the 'data-action' attribute of the target. The target's
    # value is passed along through the event.
    change: (e) =>
      $target = $(e.target)
      @api.trigger("#{$target.attr("data-action")}", $target.val()) if $target.attr("data-action")
