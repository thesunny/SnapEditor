# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
require ["jquery.custom", "snapeditor.pre"], ($) ->
  window.isIE = $.browser.msie
  #window.isIE7 = isIE and parseInt($.browser.version, 10) == 7
  #window.isIE8 = isIE and parseInt($.browser.version, 10) == 8
  #window.isIE9 = isIE and parseInt($.browser.version, 10) == 9
  #window.isIE10 = isIE and parseInt($.browser.version, 10) == 10
  window.isIE7 = isIE and document.documentMode == 7
  window.isIE8 = isIE and document.documentMode == 8
  window.isIE9 = isIE and document.documentMode == 9
  window.isIE10 = isIE and document.documentMode == 10
  window.isGecko = $.browser.mozilla
  window.isGecko1 = isGecko and parseInt($.browser.version, 10) == 1
  window.isWebkit = $.browser.webkit
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
