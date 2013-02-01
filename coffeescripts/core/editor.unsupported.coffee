# This class is used when the browser is not supported. It does nothing but
# stub all the public API methods.
define ["core/browser"], (Browser) ->
  class UnsupportedEditor
    constructor: (el, config) ->
      SnapEditor.DEBUG("Webkit: #{Browser.isWebkit}")
      SnapEditor.DEBUG("Gecko: #{Browser.isGecko}")
      SnapEditor.DEBUG("Gecko1: #{Browser.isGecko1}")
      SnapEditor.DEBUG("IE: #{Browser.isIE}")
      SnapEditor.DEBUG("IE7: #{Browser.isIE7}")
      SnapEditor.DEBUG("IE8: #{Browser.isIE8}")
      SnapEditor.DEBUG("IE9: #{Browser.isIE9}")
      SnapEditor.DEBUG("W3C Ranges: #{Browser.hasW3CRanges}")
      SnapEditor.DEBUG("Supported: #{Browser.isSupported}")

      @unsupported = true

    getContents: ->
      ""

  return UnsupportedEditor
