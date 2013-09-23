# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom"], ($) ->
  isIE = $.browser.msie
  #isIE7 = isIE and parseInt($.browser.version, 10) == 7
  #isIE8 = isIE and parseInt($.browser.version, 10) == 8
  #isIE9 = isIE and parseInt($.browser.version, 10) == 9
  isIE7 = isIE and document.documentMode == 7
  isIE8 = isIE and document.documentMode == 8
  isIE9 = isIE and document.documentMode == 9
  isIE10 = isIE and document.documentMode == 10

  isGecko = $.browser.mozilla
  isGecko1 = isGecko and parseInt($.browser.version, 10) == 1

  isWebkit = $.browser.webkit

  hasW3CRanges = !!window.getSelection

  isSupported = isIE7 || isIE8 || isIE9 || isIE10 || isGecko || isWebkit

  return {
    isIE: isIE
    isIE7: isIE7
    isIE8: isIE8
    isIE9: isIE9
    isIE10: isIE10
    isGecko: isGecko
    isGecko1: isGecko1
    isWebkit: isWebkit
    hasW3CRanges: hasW3CRanges
    isSupported: isSupported
  }
