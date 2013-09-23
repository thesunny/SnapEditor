# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
# This class is used when the browser is not supported. It does nothing but
# stub all the public API methods.
define ["core/browser"], (Browser) ->
  class UnsupportedEditor
    constructor: (el, config) ->
      @unsupported = true

    getContents: ->
      ""
