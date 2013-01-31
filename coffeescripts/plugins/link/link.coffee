define ["jquery.custom", "core/browser", "core/helpers", "plugins/link/link.mirrorInput"], ($, Browser, Helpers, MirrorInput) ->
  class Link
    register: (@api) ->

    getUI: (ui) ->
      link = ui.button(action: "link", description: @api.lang.link, shortcut: "Ctrl+K", icon: { url: @api.assets.image("link.png"), width: 24, height: 24, offset: [3, 3] })
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
      @dialog = ui.dialog(@api.lang.linkInsertTitle,
        """
          <div class="error" style="display: none;"></div>
          <form class="link_form">
            <div class="field_container">
              <label class="label_left">#{@api.lang.linkUrl}</label>
              <input class="link_href" type="text" />
            </div>
            <div class="field_container link_text_container">
              <label class="label_left">#{@api.lang.linkCaption}</label>
              <input class="link_text" type="text" />
            </div>
            <div class="field_container">
              <label class="label_left"></label>
              <label class="link_new_window_text">
                <input class="link_new_window" type="checkbox" />
                #{@api.lang.linkNewWindow}
              </label>
            </div>
            <div class="buttons">
              <label class="label_left"></label>
              <input class="link_submit submit button" type="submit" value="#{@api.lang.linkCreate}" />
              <input class="link_remove delete button" type="button" value="#{@api.lang.linkRemove}" />
              <input class="link_cancel cancel button" type="button" value="#{@api.lang.formCancel}" />
            </div>
          </form>
        """
      )

    setupDialog: ->
      unless @$dialog
        @dialog.on("snapeditor.dialog_hide", @handleDialogHide)
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
        # Only in IE8, if the form is not present on page load, it does not
        # know how to submit the form when hitting enter. IE8 scans the page
        # on load for any submit buttons and attaches the enter-to-submit at
        # that time. This is a known bug.
        # Firefox does not "absorb" the enter when hitting enter in an input
        # field. After hitting enter from an input field, it submits the form,
        # adds the link, then adds a newline in the editor. To prevent this
        # from happening, we handle the enter key in the inputs directly.
        if Browser.isIE8 or Browser.isGecko
          @$href.keydown(@handleEnter)
          @$text.keydown(@handleEnter)
          @$newWindow.keydown(@handleEnter)

    handleDialogHide: =>
      @mirrorInput.deactivate()
      # TODO: May want to move this to the dialog instead.
      # In Webkit and Firefox, we have to manually move the focus back to the
      # editor.
      # @api.win.focus() must be used in Webkit because @api.el.focus() makes
      # the page jump.
      # @api.el.focus() must be used in Firefox because @api.win.focus() does
      # nothing.
      # This affects IE as it makes the page jump to where the cursor is.
      @api.win.focus() if Browser.isWebkit
      @api.el.focus() if Browser.isGecko
      @range.select()

    prepareForm: ->
      @resetForm()
      if @$link.length > 0
        @prepareUpdateForm()
      else
        @prepareAddForm()

    prepareAddForm: ->
      if @imageSelected
        @dialog.setTitle(@api.lang.linkImageInsertTitle)
        @$textContainer.hide()
      else
        @dialog.setTitle(@api.lang.linkInsertTitle)
        @$textContainer.show()
        @$text.attr("value", @range.getText())
      @$submit.attr("value", @api.lang.linkCreate)
      @$remove.hide()

    prepareUpdateForm: ->
      @$href.attr("value", @$link.attr("href"))
      if @imageSelected
        @dialog.setTitle(@api.lang.linkImageEditTitle)
        @$text.hide()
      else
        @dialog.setTitle(@api.lang.linkEditTitle)
        @$textContainer.show()
        @$text.attr("value", @$link.text())
      @$newWindow.prop("checked", !!@$link.attr("target"))
      @$submit.attr("value", @api.lang.linkUpdate)
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
        @range = @api.getRange()
        [startParent, endParent] = @api.getParentElements("a")
        @$link = $(startParent || endParent)
        @imageSelected = @isImageSelected()
        @setupDialog()
        @prepareForm()
        @mirrorInput.activate()
        @dialog.show()
        # TODO: Consider sticking this into the dialog when showing.
        # In Firefox, if we don't set the focus on the dialog first, the focus on
        # the input will not work.
        # In Webkit, if we don't set the focus on the window first, the second
        # time the dialog is shown, the focus on the input will not work.
        # We use window.focus() instead of @$dialog[0].focus() because
        # focusing on the dialog does not fix Webkit. Focusing on the window
        # fixes Firefox.
        # This does not affect IE.
        window.focus()
        @$href[0].focus()

    hide: =>
      @dialog.hide()

    showError: (msg) ->
      @$error.html(msg).show()

    hideError: ->
      @$error.hide().empty()

    handleEnter: (e) =>
      if Helpers.keysOf(e) == "enter"
        @$form.submit()
        # Need to return false to prevent IE8 from beeping.
        return false

    submit: (e) =>
      e.preventDefault()
      href = $.trim(@$href.attr("value"))
      text = $.trim(@$text.attr("value")) unless @imageSelected
      errors = []
      # TODO: Validation could be beefed up. However, this is good enough for
      # now. Instead of having a full URL validation check, we just check for
      # spaces because a space in the URL screws up Firefox. We may want to
      # revisit this someday if there is demand for better validation.
      errors.push(@api.lang.linkURLBlankError) unless href
      errors.push(@api.lang.linkURLInvalidError) if !!href.match(/\s+/)
      errors.push(@api.lang.linkCaptionBlankError) if typeof text != "undefined" && !text
      if errors.length > 0
        message = "<div>#{@api.lang.formErrorMessage}</div><ul>"
        message += "<li>#{error}</li>" for error in errors
        message += "</ul>"
        @showError(message)
      else
        @hideError()
        @hide()
        @link()

    remove: =>
      Helpers.replaceWithChildren(@$link[0]) if @$link.length > 0
      @hide()

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
          @range.insert($link[0])
        else
          if @imageSelected
            @range.surroundContents($link[0])
          else
            @range.delete()
            @range.insert($link[0])
      @update()

    update: ->
      # In Webkit, after the toolbar is clicked, the focus hops to the parent
      # window. We need to refocus it back into the iframe. Focusing breaks IE
      # and kills the range so the focus is only for Webkit. It does not affect
      # Firefox.
      @api.win.focus() if Browser.isWebkit
      @api.clean()

  return Link
