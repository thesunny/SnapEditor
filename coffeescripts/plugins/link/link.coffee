define ["jquery.custom", "core/browser", "core/helpers"], ($, Browser, Helpers) ->
  class Link
    register: (@api) ->

    getUI: (ui) ->
      link = ui.button(action: "link", description: "Insert Link", shortcut: "Ctrl+K", icon: { url: @api.assets.image("link.png"), width: 24, height: 24, offset: [3, 3] })
      @generateDialog(ui)
      return {
        "toolbar:default": "link"
        link: link
      }

    getActions: ->
      return {
        link: @show
      }

    getKeyboardShortcuts: ->
      return {
        "ctrl.k": "link"
      }

    generateDialog: (ui) ->
      @dialog = ui.dialog("""
        <div class="error" style="display: none;"></div>
        <form class="link_form">
          <div>URL: <input class="link_href" type="text" /></div>
          <div class="link_normalized_href"></div>
          <div>Open in a new window? <input class="link_new_window" type="checkbox" /></div>
          <div>
            <input class="link_submit" type="submit" value="Link" />
            <input class="link_remove" type="button" value="Remove" />
            <a class="link_cancel" href="#">Cancel</a>
          </div>
        </form>
      """)

    setupDialog: ->
      unless @$dialog
        @dialog.on("hide.dialog", @handleDialogHide)
        @$dialog = $(@dialog.getEl())
        @$error = @$dialog.find(".error")
        @$form = @$dialog.find(".link_form").on("submit", @submit)
        @$href = @$dialog.find(".link_href")
        @$newWindow = @$dialog.find(".link_new_window")
        @$remove = @$dialog.find(".link_remove").on("click", @remove)
        @$cancel = @$dialog.find(".link_cancel").on("click", @cancel)

    handleDialogHide: =>
      # TODO: May want to move this to the dialog instead.
      # In Firefox, we have to manually move the focus back to the editor. All
      # other browsers do this automatically.
      # In Webkit, the focus is set back to the editor for typing, but the
      # keyboard shortcuts don't work unless we manually move the focus back to
      # the editor.
      # This does not effect IEs so it is left in for consistency.
      @api.el.focus()
      @range.select()

    prepareForm: ->
      @resetForm()
      if @$link.length > 0
        @$href.attr("value", @$link.attr("href"))
        @$newWindow.prop("checked", !!@$link.attr("target"))
        @$remove.show()
      else
        @$remove.hide()

    resetForm: ->
      @$href.attr("value", "")
      @$newWindow.prop("checked", false)
      @hideError()

    show: =>
      if @api.isValid()
        # Save the range.
        @range = @api.range()
        [startParent, endParent] = @range.getParentElements("a")
        @$link = $(startParent || endParent)
        @setupDialog()
        @prepareForm()
        @dialog.show()
        # TODO: Consider sticking this into the dialog when showing.
        # In Firefox, if we don't set the focus on the dialog first, the focus on
        # the input will not work. This does not effect other browsers so it has
        # been left in.
        @$dialog[0].focus()
        @$href[0].focus()

    hide: =>
      @dialog.hide()

    showError: (msg) ->
      @$error.html(msg).show()

    hideError: ->
      @$error.hide().empty()

    submit: (e) =>
      e.preventDefault()
      href = $.trim(@$href.attr("value"))
      errors = []
      if href.length == 0
        @showError("Please provide a URL")
      else
        @hideError()
        @hide()
        @link()

    remove: =>
      Helpers.replaceWithChildren(@$link[0]) if @$link.length > 0

    cancel: (e) =>
      e.preventDefault()
      @hide()

    normalize: (url) ->
      normalizedUrl = url
      if /@/.test(url)
        # Normalize email.
        normalizedUrl = "mailto:#{url}"
      else
        matches = url.match(/^([a-z]+:|)(\/\/.*)$/)
        if matches
          # Normalize URL.
          protocol = if matches[1].length > 0 then matches[1] else "http:"
          normalizedUrl = protocol + matches[2]
        else
          # Normalize path.
          normalizedUrl = "http://#{url}" unless url.charAt(0) == "/"
      normalizedUrl

    # TODO:
    # NOTE:
    # You cannot use this method to call up a prompt because the preventDefault()
    # does not work properly in Firefox. The default action (go to search box)
    # still fires for some reason. The solution is probably to use our own
    # input boxes so we'll have to do that by ourself later. For now, we just
    # use default 'http://'
    #
    # I did try using the setTimeout but in Firefox, the function loses its
    # context making it difficult to locate the insertLinkDialog method that
    # we used to launch the prompt. IE isn't the only quirky browser.
    #
    # TODO: In opera, preventDefault doesn't work so it keeps popping up a dialog.
    link: =>
      # TODO-iframe
      href = @normalize($.trim(@$href.attr("value")))
      newWindow = @$newWindow.prop("checked")
      $link = $("<a href=\"#{href}\"></a>")
      $link.attr("target", "_blank") if newWindow
      @api.insertLink($link[0])
      @update()

    update: ->
      @api.clean()
      @api.update()

  return Link
