define ["cs!jquery.custom"], ($) ->
  isIE = $.browser.msie
  isIE7 = isIE and parseInt($.browser.version, 10) == 7
  isIE8 = isIE and parseInt($.browser.version, 10) == 8
  isIE9 = isIE and parseInt($.browser.version, 10) == 9

  isGecko = $.browser.mozilla
  isGecko1 = isGecko and parseInt($.browser.version, 10) == 1

  isWebkit = $.browser.webkit

  hasW3CRanges = !!window.getSelection

  return Browser =
    isIE: isIE,
    isIE7: isIE7,
    isIE8: isIE8,
    isIE9: isIE9,
    isGecko: isGecko,
    isGecko1: isGecko1,
    isWebkit: isWebkit,
    hasW3CRanges: hasW3CRanges
