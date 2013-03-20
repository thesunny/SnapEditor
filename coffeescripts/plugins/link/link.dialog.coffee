define ["jquery.custom", "core/helpers", "core/browser", "core/ui/ui.dialog", "plugins/link/link.mirrorInput"], ($, Helpers, Browser, Dialog, MirrorInput) ->
  class LinkDialog extends Dialog
    getHTML: ->
      """
        <div class="error" style="display: none;"></div>
        <form class="link_form">
          <div class="field_container">
            <label class="label_left">#{@api.config.lang.linkUrl}</label>
            <input class="link_href" type="text" />
          </div>
          <div class="field_container link_text_container">
            <label class="label_left">#{@api.config.lang.linkCaption}</label>
            <input class="link_text" type="text" />
          </div>
          <div class="field_container">
            <label class="label_left"></label>
            <label class="link_new_window_text">
              <input class="link_new_window" type="checkbox" />
              #{@api.config.lang.linkNewWindow}
            </label>
          </div>
          <div class="buttons">
            <label class="label_left"></label>
            <input class="link_submit submit button" type="submit" value="#{@api.config.lang.linkCreate}" />
            <input class="link_remove delete button" type="button" value="#{@api.config.lang.linkRemove}" />
            <input class="link_cancel cancel button" type="button" value="#{@api.config.lang.formCancel}" />
          </div>
        </form>
      """
    #
    # DIALOG FUNCTIONS
    #

    setup: ->
      unless @$el
        super(html: @getHTML())
        @$error = @$el.find(".error")
        @$form = @$el.find(".link_form").on("submit", @submit)
        @$href = @$el.find(".link_href")
        @$text = @$el.find(".link_text")
        @$textContainer = @$el.find(".link_text_container")
        @$newWindow = @$el.find(".link_new_window")
        @$submit = @$el.find(".link_submit")
        @$remove = @$el.find(".link_remove").on("click", @remove)
        @$cancel = @$el.find(".link_cancel").on("click", @cancel)
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

    show: (api) ->
      super(api)
      # Save the range.
      @range = @api.getRange()
      [startParent, endParent] = @api.getParentElements("a")
      @$link = $(startParent || endParent)
      @imageSelected = @isImageSelected()
      @prepareForm()
      @mirrorInput.activate()
      @$href[0].focus()

    hide: ->
      super()
      @mirrorInput.deactivate()
      @range.select()

    #
    # FORM
    #

    prepareForm: ->
      @resetForm()
      if @$link.length > 0
        @prepareUpdateForm()
      else
        @prepareAddForm()

    prepareAddForm: ->
      if @imageSelected
        @setTitle(@api.config.lang.linkImageInsertTitle)
        @$textContainer.hide()
      else
        @setTitle(@api.config.lang.linkInsertTitle)
        @$textContainer.show()
        @$text.attr("value", @range.getText())
      @$submit.attr("value", @api.config.lang.linkCreate)
      @$remove.hide()

    prepareUpdateForm: ->
      @$href.attr("value", @$link.attr("href"))
      if @imageSelected
        @setTitle(@api.config.lang.linkImageEditTitle)
        @$text.hide()
      else
        @setTitle(@api.config.lang.linkEditTitle)
        @$textContainer.show()
        @$text.attr("value", @$link.text())
      @$newWindow.prop("checked", !!@$link.attr("target"))
      @$submit.attr("value", @api.config.lang.linkUpdate)
      @$remove.show()

    resetForm: ->
      @$href.attr("value", "")
      @$text.show().attr("value", "")
      @$newWindow.prop("checked", false)
      @hideError()

    showError: (msg) ->
      @$error.html(msg).show()

    hideError: ->
      @$error.hide().empty()

    #
    # ACTION HANDLERS
    #

    handleEnter: =>
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
      errors.push(@api.config.lang.linkURLBlankError) unless href
      errors.push(@api.config.lang.linkURLInvalidError) if !!href.match(/\s+/)
      errors.push(@api.config.lang.linkCaptionBlankError) if typeof text != "undefined" && !text
      if errors.length > 0
        message = "<div>#{@api.config.lang.formErrorMessage}</div><ul>"
        message += "<li>#{error}</li>" for error in errors
        message += "</ul>"
        @showError(dialog, message)
      else
        @hide()
        @link()

    remove: =>
      Helpers.replaceWithChildren(@$link[0]) if @$link.length > 0
      @hide()

    cancel: (e) =>
      e.preventDefault()
      @hide()

    #
    # FUNCTIONS
    #

    isImageSelected: ->
      @range.isImageSelected() || @$link.length > 0 && @$link.text().length == 0 && @$link.find("img").length > 0

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
    link: ->
      href = Helpers.normalizeURL($.trim(@$href.attr("value")))
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
      @api.clean()
