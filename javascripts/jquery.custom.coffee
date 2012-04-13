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
    while !parent.isVisible() && parent.get(0) != document.body
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
    el = this.get(0)
    before = el.style.cssText
    this.css(
      display: 'block',
      position: 'absolute',
      visibility: 'hidden'
    )
    => el.style.cssText = before

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
