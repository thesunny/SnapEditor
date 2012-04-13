define ["cs!jquery.custom", "cs!core/browser"], ($, Browser) ->
  return {
    start: ->
      $(@api.el).attr("contentEditable", true)
      # In Gecko, we need to manually turn off the automatic image resize
      # handles that Gecko gives you. This is left in for other browsers since
      # there is no harm in doing so.
      #
      # NOTE: This disables object resizing for the entire document, not just
      # for this editor.
      document.execCommand("enableObjectResizing", false, false)
  }
