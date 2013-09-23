# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["../lib/jquery", "../lib/mustache"], ->
  $ = jQuery
  # Remove both window.$ and window.jQuery.
  $.noConflict(true)

  # Shortcut for tagName.
  $.fn.tagName = ->
    return null unless this.length > 0
    this[0].tagName.toLowerCase()

  # Mimics MooTools getCoordinates.
  $.fn.getCoordinates = (withPadding = false, withBorderWidth = false) ->
    offset = this.offset()
    size = this.getSize(withPadding, withBorderWidth)
    # Round the numbers because Webkit returns decimal pixels.
    return {
      top: Math.round(offset.top)
      bottom: Math.round(offset.top + size.y)
      left: Math.round(offset.left)
      right: Math.round(offset.left + size.x)
      width: Math.round(size.x)
      height: Math.round(size.y)
    }

  # Mimics MooTools getScroll.
  $.fn.getScroll = ->
    return {
      x: this.scrollLeft()
      y: this.scrollTop()
    }

  # Mimcs MooTools getSize.
  $.fn.getSize = (withPadding = false, withBorderWidth = false) ->
    width = this.width()
    height = this.height()
    if withPadding
      padding = this.getPadding()
      width += padding.left + padding.right
      height += padding.top + padding.bottom
    if withBorderWidth
      borderWidth = this.getBorderWidth()
      width += borderWidth.left + borderWidth.right
      height += borderWidth.top + borderWidth.bottom
    return {
      x: width
      y: height
    }

  $.fn.getPadding = ->
    # Webkit returns decimal pixels. Hence parse to float first and then
    # round.
    return {
      top: Math.round(parseFloat(this.css("padding-top")))
      bottom: Math.round(parseFloat(this.css("padding-bottom")))
      left: Math.round(parseFloat(this.css("padding-left")))
      right: Math.round(parseFloat(this.css("padding-right")))
    }

  $.fn.getBorderWidth = ->
    # Webkit returns decimal pixels. Hence parse to float first and then
    # round.
    return {
      top: Math.round(parseFloat(this.css("border-top-width")) || 0)
      bottom: Math.round(parseFloat(this.css("border-bottom-width")) || 0)
      left: Math.round(parseFloat(this.css("border-left-width")) || 0)
      right: Math.round(parseFloat(this.css("border-right-width")) || 0)
    }

  # Mimics MooTools isVisible.
  $.fn.isVisible = ->
    el = this.get(0)
    !!(el.offsetHeight || el.offsetWidth)

  # Mimics MooTools measure.
  $.fn.measure = (fn) ->
    return fn.call(this) if this.isVisible()
    parent = this.parent()
    toMeasure = []
    body = this[0].ownerDocument.body
    while !parent.isVisible() && parent[0] != body
      toMeasure.push(parent.expose())
      parent = parent.parent()
    restore = this.expose()
    result = fn.call(this)
    restore()
    for res in toMeasure
      res()
    result

  # Mimics MooTools expose.
  $.fn.expose = ->
    unless this.css("display") == 'none' then return ->
    el = this[0]
    before = el.style.cssText
    this.css(
      display: 'block'
      position: 'absolute'
      visibility: 'hidden'
    )
    => el.style.cssText = before

  # Returns true if the element is a table tag.
  $.fn.isPartOfTable = ->
    $.inArray(this.tagName(), ["table", "colgroup", "col", "tbody", "thead", "tfoot", "tr", "th", "td"]) != -1

  # Returns true if the element is a list tag.
  $.fn.isList = ->
    $.inArray(this.tagName(), ["ul", "ol"]) != -1

  # Merge other into the element.
  # If this or other is part of a table, the merge will not happen.
  # If this is a list, other will be merged into the last item.
  # If other is a list, the first item will be merged into this. If the
  # resulting list is empty, the list will be removed.
  $.fn.merge = (other) ->
    $other = $(other)
    # Don't do anything if either element is part of a table.
    return if this.isPartOfTable() or $other.isPartOfTable()
    # Get the elements to merge.
    $a = if this.isList() then this.find("li").last() else this
    $b = if $other.isList() then $other.find("li").first() else $other
    # Merge other into $b into $a.
    while($b[0].childNodes[0])
      $a[0].appendChild($b[0].childNodes[0])
    # Normalize $a after the merge.
    $a[0].normalize()
    # Remove $b since it has been merged.
    $b.remove()
    # If other was a list and is now empty, remove it.
    $other.remove() if $other.isList() and $other.find("li").length == 0

  # Splits the element on the node.
  # All nodes before the given node will belong to the first element.
  # All nodes including and after the given node will belong to the second
  # element.
  # Returns the first and second element after splitting.
  $.fn.split = (node) ->
    $node = $(node)
    $first = this.clone().html("").insertBefore(this)
    while this[0].childNodes[0] and this[0].childNodes[0] != node[0]
      $first.append(this[0].childNodes[0])
    $first[0].normalize()
    return [$first, this]

  # Replaces the current element with the given el, leaving the children intact.
  $.fn.replaceElementWith = (el) ->
    $el = $(el).empty().append(this[0].childNodes)
    this.replaceWith($el)

  # Given the contexts, find all the matching contexts.
  $.fn.contexts = (contexts, untilEl = null) ->
    matchedContexts = {}
    for context in contexts
      $match = this.closest(context, untilEl)
      matchedContexts[context] = $match[0] if $match.length > 0
    return matchedContexts

  # Generic mustache render function.
  # Taken from jquery.mustache.js when using "rake jquery" to build mustache.js.
  $.mustache = (template, view, partials) ->
    Mustache.render(template, view, partials)

  # Mustache render function using the element's HTML as the template.
  # Taken from jquery.mustache.js when using "rake jquery" to build mustache.js.
  # However, this is slightly different in that it only renders the first
  # element and returns back an HTML string.
  $.fn.mustache = (view, partials) ->
    template = $.trim($(this).html())
    output = $.mustache(template, view, partials)

  return $
