window.isIE = $.browser.msie
window.isIE7 = isIE and parseInt($.browser.version, 10) == 7
window.isIE8 = isIE and parseInt($.browser.version, 10) == 8
window.isIE9 = isIE and parseInt($.browser.version, 10) == 9
window.isGecko = $.browser.mozilla
window.isGecko1 = isGecko and parseInt($.browser.version, 10) == 1
window.isWebkit = $.browser.webkit
window.hasW3CRanges = !!window.getSelection

window.p = ->
  if typeof console != "undefined" and typeof console.log != "undefined"
    if typeof console.log.apply == "undefined"
      console.log(a) for a in arguments
    else
      console.log(arguments...)
  else
    alert(a) for a in arguments

window.addEditableFixture = ->
  $('<div id="editable" contenteditable="true"></div>').prependTo("body")
