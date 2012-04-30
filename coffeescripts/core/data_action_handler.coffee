# This is used to trigger events from button clicks and select or text input
# changes. It looks for a "data-action" attribute on the target and triggers
# that event. This makes it so that there is little wiring code needed and it
# is easy to change the events and the HTML.
define ["jquery.custom"], ($) ->
  class DataActionHandler
    # $el is the container element.
    # api is the editor API object.
    constructor: (el, @api) ->
      @$el = $(el)
      # TODO: Figure out if change event propogates.
      # Listen to any change events on <select>.
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
      @$el.on("mouseup", @click)
      # Listen to any keypresses.
      @$el.on("keypress", @change)

    setClick: (e) =>
      @isClick = true

    # When anything is clicked in the el, except a <select> which is handled by
    # the change function, it looks for a "data-action" attribute on the element
    # or its ancestors and uses that to trigger the event. The target is passed
    # along through the event.
    click: (e) =>
      if @isClick
        target = e.target
        $button = $(target).closest("[data-action]:not(select)")
        if $button.length > 0
          e.preventDefault()
          e.stopPropagation()
          @api.trigger("#{$button.attr("data-action")}", target)
      @isClick = false
      # Purposely added true here because the line above sets @isClick to false.
      # Since CoffeeScript returns the last statement, if the line above was the
      # last statement of this function, it would return false. However,
      # returning false from an event handler stops propagation. This is now what
      # we want. Hence, the true below.
      return true

    # When a select is changed or a keypress occurs in the el, it triggers the
    # event specified by the 'data-action' attribute of the target. The target's
    # value is passed along through the event.
    change: (e) =>
      $target = $(e.target)
      @api.trigger("#{$target.attr("data-action")}", $target.val()) if $target.attr("data-action")

  return DataActionHandler
