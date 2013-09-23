# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom", "plugins/helpers", "core/browser", "plugins/link/link.mirrorInput"], ($, Helpers, Browser, MirrorInput) ->
  SnapEditor.dialogs.link =
    html:
      """
        <div class="error" style="display: none;"></div>
        <form class="link_form">
          <div class="field_container">
            <label class="label_left">#{SnapEditor.lang.linkUrl}</label>
            <input class="link_href" type="text" />
          </div>
          <div class="field_container link_text_container">
            <label class="label_left">#{SnapEditor.lang.linkCaption}</label>
            <input class="link_text" type="text" />
          </div>
          <div class="field_container">
            <label class="label_left"></label>
            <label class="link_new_window_text">
              <input class="link_new_window" type="checkbox" />
              #{SnapEditor.lang.linkNewWindow}
            </label>
          </div>
          <div class="buttons">
            <label class="label_left"></label>
            <input class="link_submit submit button" type="submit" value="#{SnapEditor.lang.linkCreate}" />
            <input class="link_remove delete button" type="button" value="#{SnapEditor.lang.linkRemove}" />
            <input class="link_cancel cancel button" type="button" value="#{SnapEditor.lang.cancel}" />
          </div>
        </form>
      """

    css:
      """
        .snapeditor_dialog .link_form .field_container {
          margin-bottom: 3px;
        }

        .snapeditor_dialog .link_form .buttons {
          margin-top: 15px;
        }

        .snapeditor_dialog .link_form .label_left {
          display: inline-block;
          text-align: right;
          margin-right: 5px;
          width: 5em;
        }

        .snapeditor_dialog .link_form input[type="text"] {
          width: 225px;
        }

        .snapeditor_dialog .link_form .link_new_window_text {
          font-size: 90%;
        }
      """

    onSetup: (e) ->
      @$error = $(e.dialog.find(".error"))
      @$form = $(e.dialog.find(".link_form"))
      @$href = $(e.dialog.find(".link_href"))
      @$text = $(e.dialog.find(".link_text"))
      @$textContainer = $(e.dialog.find(".link_text_container"))
      @$newWindow = $(e.dialog.find(".link_new_window"))
      @$submit = $(e.dialog.find(".link_submit"))
      @$remove = $(e.dialog.find(".link_remove"))
      @mirrorInput = new MirrorInput(@$href, @$text)

      e.dialog.on(".link_form", "submit", @submit)
      e.dialog.on(".link_remove", "click", @remove)
      e.dialog.on(".link_cancel", "click", @cancel)
      # Only in IE8, if the form is not present on page load, it does not
      # know how to submit the form when hitting enter. IE8 scans the page
      # on load for any submit buttons and attaches the enter-to-submit at
      # that time. This is a known bug.
      # Firefox does not "absorb" the enter when hitting enter in an input
      # field. After hitting enter from an input field, it submits the form,
      # adds the link, then adds a newline in the editor. To prevent this
      # from happening, we handle the enter key in the inputs directly.
      if Browser.isIE8 or Browser.isGecko
        e.dialog.on(".link_href", "keydown", @handleEnter)
        e.dialog.on(".link_text", "keydown", @handleEnter)
        e.dialog.on(".link_new_window", "keydown", @handleEnter)

    onOpen: (e) ->
      @dialog = e.dialog
      @api = e.api
      #@range = @api.getRange()
      [startParent, endParent] = @api.getParentElements("a")
      @$link = $(startParent || endParent)
      @imageSelected = @isImageSelected()
      @rangeText = @api.getText()
      @prepareForm()
      @mirrorInput.activate()
      @$href[0].focus()

    onClose: (e) ->
      @mirrorInput.deactivate()

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
        @dialog.setTitle(@api.config.lang.linkImageInsertTitle)
        @$textContainer.hide()
      else
        @dialog.setTitle(@api.config.lang.linkInsertTitle)
        @$textContainer.show()
        @$text.attr("value", @rangeText)
      @$submit.attr("value", @api.config.lang.linkCreate)
      @$remove.hide()

    prepareUpdateForm: ->
      @$href.attr("value", @$link.attr("href"))
      if @imageSelected
        @dialog.setTitle(@api.config.lang.linkImageEditTitle)
        @$text.hide()
      else
        @dialog.setTitle(@api.config.lang.linkEditTitle)
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

    handleEnter: (e) ->
      if Helpers.keysOf(e.domEvent) == "enter"
        @$form.submit()
        # Need to return false to prevent IE8 from beeping.
        return false

    submit: (e) ->
      e.domEvent.preventDefault()
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
        @showError(message)
      else
        @link()
        e.dialog.close()

    remove: (e) ->
      Helpers.replaceWithChildren(@$link[0]) if @$link.length > 0
      e.dialog.close()

    cancel: (e) ->
      e.domEvent.preventDefault()
      e.dialog.close()

    #
    # FUNCTIONS
    #

    isImageSelected: ->
      @api.isImageSelected() || @$link.length > 0 && @$link.text().length == 0 && @$link.find("img").length > 0

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
          @api.insert($link[0])
        else
          if @imageSelected
            @api.surroundContents($link[0])
          else
            @api.delete()
            @api.insert($link[0])
      @api.clean()


  SnapEditor.actions.link = (e) -> e.api.openDialog("link", e)

  SnapEditor.buttons.link = Helpers.createButton("link", "ctrl+k", onInclude: (e) -> e.api.addWhitelistRule("Link", "a[href, target]"))

  SnapEditor.insertStyles("link", Helpers.createStyles("link", 21 * -26))
