# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
# require ["jquery.custom", "snapeditor.pre"], ($) ->

# Code borrowed from jQuery migrate. Versions of jQuery older than 1.9
# doesn't include $.browser but we need it.
uaMatch = (ua) ->
  ua = ua.toLowerCase()

  match = /(chrome)[ \/]([\w.]+)/.exec( ua ) ||
    /(webkit)[ \/]([\w.]+)/.exec( ua ) ||
    /(opera)(?:.*version|)[ \/]([\w.]+)/.exec( ua ) ||
    /(msie) ([\w.]+)/.exec( ua ) ||
    ua.indexOf("compatible") < 0 && /(mozilla)(?:.*? rv:([\w.]+)|)/.exec( ua ) ||
    [];

  return {
    browser: match[ 1 ] || "",
    version: match[ 2 ] || "0"
  }

matched = uaMatch(navigator.userAgent)
browser = {}

if matched.browser
  browser[ matched.browser ] = true
  browser.version = matched.version

# Chrome is Webkit, but Webkit is also Safari.
if browser.chrome
  browser.webkit = true
else if browser.webkit
  browser.safari = true

window.isIE = browser.msie || navigator.userAgent.indexOf("Trident/7.0") != -1
#window.isIE7 = isIE and parseInt($.browser.version, 10) == 7
#window.isIE8 = isIE and parseInt($.browser.version, 10) == 8
#window.isIE9 = isIE and parseInt($.browser.version, 10) == 9
#window.isIE10 = isIE and parseInt($.browser.version, 10) == 10
window.ieVersion = isIE and document.documentMode
window.isIE7 = isIE and window.ieVersion == 7
window.isIE8 = isIE and window.ieVersion == 8
window.isIE9 = isIE and window.ieVersion == 9
window.isIE10 = isIE and window.ieVersion == 10
window.isIE11 = isIE and window.ieVersion == 11
window.isGecko = browser.mozilla and !isIE
window.isGecko1 = isGecko and parseInt(browser.version, 10) == 1
window.isWebkit = browser.webkit
window.hasW3CRanges = !!window.getSelection

# Puts.
window.p = ->
  # We can't just use
  #   if console
  # or
  #   if !!console
  # because IE craps all over the place when console is undefined
  # complaining that it is undefined.
  #
  # We also can't just stop at console.log because CoffeeScript compiles it
  # down to
  #   console.log.apply(...)
  # Apparently, in IE, if you open the developer tool bar (F12), it adds
  # console.log. Unfortunately, for some crazy reason, console.log.apply is
  # undefined. Hence, even though IE now has the ability to console.log, we
  # can't use it.
  if typeof console != "undefined" and typeof console.log != "undefined"
    if typeof console.log.apply == "undefined"
      console.log(a) for a in arguments
    else
      console.log(arguments...)
  else
    alert(a) for a in arguments

window.addEditableFixture = (doc = document) ->
  $(doc.createElement("div")).attr(id: "editable", contenteditable: true).prependTo(doc.body)

# Lowercase the string.
# Remove ", \n, \r, and zero width no break space.
window.clean = (s) ->
  s.toLowerCase().replace(/["\n\r\t\ufeff]/g, "")

window.fireIEEvent = (el, eventName) ->
  if document.createEvent
    event = document.createEvent('HTMLEvents')
    event.initEvent(eventName,true,true)
  else if document.createEventObject # IE < 9
    event = document.createEventObject();
    event.eventType = eventName;
  else
    throw "Can't find method to create Event"
  event.eventName = eventName;

  if el.dispatchEvent
    el.dispatchEvent(event)
  else if el.fireEvent
    el.fireEvent('on'+eventName, event)
  else
    throw "Can't find method to fire Event"

