# This class is used when the browser is not supported. It does nothing but
# stub all the public API methods.
define ["core/browser"], (Browser) ->
  class UnsupportedEditor
    constructor: (el, config) ->
      @unsupported = true

    getContents: ->
      ""

  return UnsupportedEditor
