define ["jquery.custom", "core/browser", "core/helpers", "plugins/link/link.mirrorInput"], ($, Browser, Helpers, MirrorInput) ->
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
      @dialog = ui.dialog("Insert Link",
        """
          <div class="error" style="display: none;"></div>
          <form class="link_form">
            <div class="field_container">
              <label class="label_left">URL:</label>
              <input class="link_href" type="text" />
            </div>
            <div class="field_container link_text_container">
              <label class="label_left">Caption:</label>
              <input class="link_text" type="text" />
            </div>
            <div class="field_container">
              <label class="label_left"></label>
              <label class="link_new_window_text">
                <input class="link_new_window" type="checkbox" />
                Open link in new window
              </label>
            </div>
            <div class="buttons">
              <label class="label_left"></label>
              <input class="link_submit" type="submit" value="Create Link" />
              <input class="link_remove" type="button" value="Remove" />
              <input class="link_cancel" type="button" value="Cancel" />
            </div>
          </form>
        """
      )

    setupDialog: ->
      unless @$dialog
        @dialog.on("hide.dialog", @handleDialogHide)
        @$dialog = $(@dialog.getEl())
        @$error = @$dialog.find(".error")
        @$form = @$dialog.find(".link_form").on("submit", @submit)
        @$href = @$dialog.find(".link_href")
        @$text = @$dialog.find(".link_text")
        @$textContainer = @$dialog.find(".link_text_container")
        @$newWindow = @$dialog.find(".link_new_window")
        @$submit = @$dialog.find(".link_submit")
        @$remove = @$dialog.find(".link_remove").on("click", @remove)
        @$cancel = @$dialog.find(".link_cancel").on("click", @cancel)
        @mirrorInput = new MirrorInput(@$href, @$text)

    handleDialogHide: =>
      @mirrorInput.deactivate()
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
        @prepareUpdateForm()
      else
        @prepareAddForm()

    prepareAddForm: ->
      if @imageSelected
        @dialog.setTitle("Insert Image Link")
        @$textContainer.hide()
      else
        @dialog.setTitle("Insert Link")
        @$textContainer.show()
      @$submit.attr("value", "Create Link")
      @$remove.hide()

    prepareUpdateForm: ->
      @$href.attr("value", @$link.attr("href"))
      if @imageSelected
        @dialog.setTitle("Edit Image Link")
        @$text.hide()
      else
        @dialog.setTitle("Edit Link")
        @$text.show().attr("value", @$link.text())
      @$newWindow.prop("checked", !!@$link.attr("target"))
      @$submit.attr("value", "Update Link")
      @$remove.show()

    resetForm: ->
      @$href.attr("value", "")
      @$text.show().attr("value", "")
      @$newWindow.prop("checked", false)
      @hideError()

    isImageSelected: ->
      @range.isImageSelected() || @$link.length > 0 && @$link.text().length == 0 && @$link.find("img").length > 0

    show: =>
      if @api.isValid()
        # Save the range.
        @range = @api.range()
        [startParent, endParent] = @range.getParentElements("a")
        @$link = $(startParent || endParent)
        @imageSelected = @isImageSelected()
        @setupDialog()
        @prepareForm()
        @mirrorInput.activate()
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
      text = $.trim(@$text.attr("value")) unless @imageSelected
      errors = []
      errors.push("URL cannot be blank") unless href
      errors.push("Caption cannot be blank") if typeof text != "undefined" && !text
      if errors.length > 0
        message = "<div>Please fix the following errors:</div><ul>"
        message += "<li>#{error}</li>" for error in errors
        message += "</u>"
        @showError(message)
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
      href = @normalize($.trim(@$href.attr("value")))
      text = $.trim(@$text.attr("value")) unless @imageSelected
      newWindow = @$newWindow.prop("checked")
      if @$link.length > 0
        @$link.attr("href", href)
        @$link.text(text) if text
        if newWindow
          @$link.attr("target", "_blank")
        else
          @$link.removeAttr("target")
      else
        $link = $(@api.createElement("a"))
        $link.attr("href", href)
        $link.text(text) if text
        $link.attr("target", "_blank") if newWindow
        if @api.isCollapsed()
          @range.paste($link[0])
        else
          if @imageSelected
            @range.surroundContents($link[0])
          else
            @range.paste($link[0])
      @update()

    update: ->
      # In Webkit, after the toolbar is clicked, the focus hops to the parent
      # window. We need to refocus it back into the iframe. Focusing breaks IE
      # and kills the range so the focus is only for Webkit. It does not affect
      # Firefox.
      @api.win.focus() if Browser.isWebkit
      @api.clean()
      @api.update()

  return Link
