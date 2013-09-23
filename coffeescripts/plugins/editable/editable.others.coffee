# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define [], ->
  return {
    start: (api) ->
      api.el.contentEditable = true
      # In Gecko, we need to manually turn off the automatic image resize
      # handles that Gecko gives you. This is left in for other browsers since
      # there is no harm in doing so.
      #
      # NOTE: This disables object resizing for the entire document, not just
      # for this editor.
      api.doc.execCommand("enableObjectResizing", false, false)
  }
