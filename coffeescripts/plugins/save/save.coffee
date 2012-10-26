define ["jquery.custom", "core/browser", "core/helpers"], ($, Browser, Helpers) ->
  class Save
    register: (@api) ->
      @checkOptions()
      @api.on("ready.editor", @activate)
      @api.on("tryDeactivate.editor", @cancel)
      @api.on("deactivate.editor", @deactivate)
      @api.disableImmediateDeactivate()

    checkOptions: ->
      throw "Missing 'onSave' callback config" unless @api.config['onSave']

    getUI: (ui) ->
      save = ui.button(action: "save", description: @api.lang.save, shortcut: "Ctrl+S", icon: { url: @api.assets.image("disk.png"), width: 24, height: 24, offset: [3, 3] })
      cancel = ui.button(action: "cancel", description: @api.lang.cancel, icon: { url: @api.assets.image("cross.png"), width: 24, height: 24, offset: [3, 3] })
      @generateDialog(ui)

      return {
        "toolbar:default": "savecancel",
        savecancel: [save, cancel],
        save: save
        cancel: cancel
      }

    getActions: ->
      return {
        save: @save
        cancel: @cancel
      }

    getKeyboardShortcuts: ->
      return {
        "ctrl.s": "save"
        # TODO: In Chrome, when an element is contenteditable, the esc keydown
        # event does not get triggered. However, the esc keyup event does
        # trigger. Unfortunately, the target is the body and not the element
        # itself. Removing the shortcut until a solution can be found.
        #"esc": "cancel"
      }

    generateDialog: (ui) ->
      @saveDialog = ui.dialog("Save/Cancel",
        """
          <div class="save_dialog">
            <div class="message">#{@api.lang.saveExitMessage}</div>
            <div class="buttons">
              <button class="save submit button">#{@api.lang.saveSaveButton}</button>
              <button class="cancel button">#{@api.lang.formCancel}</button>
            </div>
            <div class="discard_message">
              #{@api.lang.saveOr} <a class="discard" href="javascript:void(null);">#{@api.lang.saveDiscardChanges}</a>
            </div>
          </div>
        """
      )
      @$saveDialog = $(@saveDialog.getEl())
      @$save = @$saveDialog.find(".save").on("click", @save)
      @$cancel = @$saveDialog.find(".cancel").on("click", @resume)
      @$discard = @$saveDialog.find(".discard").on("click", @discard)

      @errorDialog = ui.dialog(@api.lang.saveErrorTitle,
        """
          <div class="error"></div>
          <button class="okay">#{@api.lang.formOk}</button>
        """
      )
      @$errorDialog = $(@errorDialog.getEl())
      @$error = @$errorDialog.find(".error")
      @$okay = @$errorDialog.find(".okay").on("click", @errorDialog.hide)

    activate: =>
      @setOriginalHTML()
      $(window).on("beforeunload", @leavePage)

    deactivate: =>
      @unsetOriginalHTML()
      $(window).off("beforeunload", @leavePage)

    setOriginalHTML: =>
      @originalHTML = @api.getContents()

    unsetOriginalHTML: =>
      @originalHTML = null

    showErrorDialog: (message) ->
      @$error.text(message)
      @errorDialog.show()

    isEdited: ->
      @api.getContents() != @originalHTML

    save: =>
      result = @api.save()
      if typeof result == "string"
        @showErrorDialog(result)
      else
        @api.deactivate()
      @saveDialog.hide()

    cancel: =>
      if @isEdited()
        @saveDialog.show()
      else
        @api.deactivate()

    resume: =>
      @saveDialog.hide()
      # In Webkit and Firefox, we have to manually move the focus back to the
      # editor.
      # @api.win.focus() must be used in Webkit because @api.el.focus() makes
      # the page jump.
      # @api.el.focus() must be used in Firefox because @api.win.focus() does
      # nothing.
      # This affects IE as it makes the page jump to where the cursor is.
      @api.win.focus() if Browser.isWebkit
      @api.el.focus() if Browser.isGecko

    discard: =>
      @saveDialog.hide()
      @api.setContents(@originalHTML)
      @api.deactivate()

    leavePage: (e) =>
      return @api.lang.saveLeavePageMessage if @isEdited()
      # Force an empty return because IE requires an empty return in order to
      # not show a dialog. If you return true or null, a dialog still shows.
      # An empty return does not affect other browsers.
      return

  return Save
