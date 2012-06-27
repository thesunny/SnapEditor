define ["jquery.custom", "core/helpers", "core/events"], ($, Helpers, Events) ->
  class Dialog
    constructor: (template, @html, @classname = "") ->
      @$template = $(template)

    getEl: ->
      unless @$el
        @id = "snapeditor_dialog_#{Math.floor(Math.random() * 99999)}"
        @$el = $(@$template.
          mustache(html: @html, class: @classname)).
          attr("id", @id).
          addClass("snapeditor_ignore_deactivate").
          css("position", "absolute").
          hide().
          appendTo("body")
      @$el[0]

    show: =>
      $(@getEl()).css(@getStyles()).show()
      $(document).on("click", @tryMouseHide)
      $(document).on("keyup", @tryKeyHide)

    hide: =>
      $(@getEl()).hide()
      $(document).off("click", @tryMouseHide)
      $(document).off("keyup", @tryKeyHide)
      @trigger("hide.dialog")

    tryMouseHide: (e) =>
      $target = $(e.target)
      @hide() if $target.closest("##{@id}").length == 0

    tryKeyHide: (e) =>
      @hide() if Helpers.keysOf(e) == "esc"

    getStyles: ->
      elSize = $(@getEl()).getSize()
      windowSize = $(window).getSize()
      windowScroll = $(window).getScroll()
      return {
        top: windowScroll.y + ((windowSize.y - elSize.y) / 2)
        left: windowScroll.x + ((windowSize.x - elSize.x) / 2)
      }

  Helpers.include(Dialog, Events)

  return Dialog
