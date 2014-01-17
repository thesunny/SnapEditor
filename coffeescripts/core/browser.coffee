# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom"], ($) ->
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

  isIE = browser.msie || navigator.userAgent.indexOf("Trident/7.0") != -1
  ieVersion = isIE and document.documentMode
  isIE7 = isIE and ieVersion == 7
  isIE8 = isIE and ieVersion == 8
  isIE9 = isIE and ieVersion == 9
  isIE10 = isIE and ieVersion == 10
  isIE11 = isIE and ieVersion == 11

  isGecko = browser.mozilla and !isIE
  isGecko1 = isGecko and parseInt(browser.version, 10) == 1

  isWebkit = browser.webkit

  hasW3CRanges = !!window.getSelection

  isSupported = isIE7 || isIE8 || isIE9 || isIE10 || isIE11 || isGecko || isWebkit

  return {
    isIE: isIE
    ieVersion: ieVersion
    isIE7: isIE7
    isIE8: isIE8
    isIE9: isIE9
    isIE10: isIE10
    isIE11: isIE11
    isGecko: isGecko
    isGecko1: isGecko1
    isWebkit: isWebkit
    hasW3CRanges: hasW3CRanges
    isSupported: isSupported
  }
