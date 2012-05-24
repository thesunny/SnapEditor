define ["../lib/jquery", "../lib/mustache"], ->
  $ = jQuery
  $.noConflict()

  # Shortcut for tagName.
  $.fn.tagName = ->
    this[0].tagName.toLowerCase()

  # Mimics MooTools getCoordinates.
  $.fn.getCoordinates = ->
    offset = this.offset()
    width = this.width()
    height = this.height()
    return {
      top: offset.top,
      bottom: offset.top + height,
      left: offset.left,
      right: offset.left + width,
      width: width,
      height: height
    }

  # Mimics MooTools getScroll.
  $.fn.getScroll = ->
    return {
      x: this.scrollLeft(),
      y: this.scrollTop()
    }

  # Mimcs MooTools getSize.
  $.fn.getSize = ->
    return {
      x: this.width(),
      y: this.height()
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
    while !parent.isVisible() && parent[0] != document.body
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
      display: 'block',
      position: 'absolute',
      visibility: 'hidden'
    )
    => el.style.cssText = before

  # Returns true if the element is a table tag.
  $.fn.isPartOfTable = ->
    $.inArray(this.tagName(), ["table", "colgroup", "col", "tbody", "thead", "tfoot", "tr", "th", "td"]) != -1

  # Returns true if the element is a list tag.
  $.fn.isPartOfList = ->
    $.inArray(this.tagName(), ["ul", "ol", "li"]) != -1

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
    $a = if this.isPartOfList() then this.find("li").last() else this
    $b = if $other.isPartOfList() then $other.find("li").first() else $other
    # Merge other into $b into $a.
    while($b[0].childNodes[0])
      $a[0].appendChild($b[0].childNodes[0])
    # Normalize $a after the merge.
    $a[0].normalize()
    # Remove $b since it has been merged.
    $b.remove()
    # If other was a list and is now empty, remove it.
    $other.remove() if $other.isPartOfList() and $other.find("li").length == 0

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
    return [$first, this]

  # Replaces the current element with the given el, leaving the children intact.
  $.fn.replaceElementWith = (el) ->
    $el = $(el).append(this[0].childNodes)
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
