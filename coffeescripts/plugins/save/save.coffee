# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom", "core/helpers"], ($, Helpers) ->
  save =
    #
    # PLUGIN EVENT HANDLERS
    #

    activate: (@api) ->
      @setOriginalHTML()
      self = this
      @leavePageHandler = -> self.leavePage()
      $(window).on("beforeunload", @leavePageHandler)

    deactivate: (api) ->
      @unsetOriginalHTML()
      $(window).off("beforeunload", @leavePageHandler)

    leavePage: ->
      return @api.config.lang.saveLeavePageMessage if @isEdited()
      # Force an empty return because IE requires an empty return in order to
      # not show a dialog. If you return true or null, a dialog still shows.
      # An empty return does not affect other browsers.
      return

    tryDeactivate: (e) ->
      if @isEdited()
        if @api.config.onUnsavedChanges
          @api.config.onUnsavedChanges(e)
        else
          @api.openDialog("savePrompt", e)
      else
        @api.deactivate()

    #
    # DIALOG EVENT HANDLERS
    #

    save: ->
      result = "onSave config was never defined."
      result = @api.config.onSave(api: @api, html: @api.getContents()) if @api.config.onSave
      result
      if typeof result == "string"
        @api.openDialog("error", { api: @api }, { title: SnapEditor.lang.saveErrorTitle, error: result })
      else
        @api.deactivate()

    discard: ->
      @api.el.innerHTML = @originalHTML
      @api.deactivate()

    #
    # FUNCTIONS
    #

    setOriginalHTML: ->
      # Unicode zero-width no-break spaces are changed to HTML entities to
      # match api.getContents().
      regexp = new RegExp(Helpers.zeroWidthNoBreakSpaceUnicode, "g")
      @originalHTML = $.trim(@api.el.innerHTML.replace(regexp, Helpers.zeroWidthNoBreakSpace))

    unsetOriginalHTML: ->
      @originalHTML = null

    isEdited: ->
      @api.getContents() != @originalHTML

  SnapEditor.dialogs.savePrompt =
    title: SnapEditor.lang.saveTitle

    html:
      """
        <div class="save_dialog">
          <div class="message">#{SnapEditor.lang.saveExitMessage}</div>
          <div class="buttons">
            <button class="save submit button">#{SnapEditor.lang.saveSaveButton}</button>
            <button class="cancel button">#{SnapEditor.lang.cancel}</button>
          </div>
          <div class="discard_message">
            #{SnapEditor.lang.saveOr} <a class="discard" href="javascript:void(null);">#{SnapEditor.lang.saveDiscardChanges}</a>
          </div>
        </div>
      """

    onSetup: (e) ->
      e.dialog.on(".save", "click", (e) ->
        e.dialog.close()
        save.save()
      )
      e.dialog.on(".cancel", "click", (e) ->
        e.dialog.close()
      )
      e.dialog.on(".discard", "click", (e) ->
        e.dialog.close()
        save.discard()
      )

  SnapEditor.actions.save = -> save.save()
  SnapEditor.actions.discard = -> save.discard()

  include = (e) ->
    e.api.config.behaviours.push("save")
    e.api.config.onTryDeactivate or= (e) -> save.tryDeactivate(e)
  $.extend(SnapEditor.buttons,
    save: Helpers.createButton("save", "ctrl+s", onInclude: include)
    # TODO: In Chrome, when an element is contenteditable, the esc keydown
    # event does not get triggered. However, the esc keyup event does
    # trigger. Unfortunately, the target is the body and not the element
    # itself. Removing the shortcut until a solution can be found.
    discard: Helpers.createButton("discard", "", onInclude: include)
  )

  SnapEditor.behaviours.save =
    onBeforeActivate: (e) -> save.activate(e.api) if e.api.config.onSave
    onDeactivate: (e) -> save.deactivate() if e.api.config.onSave

  styles = """
    .save_dialog .buttons {
      margin-top: 20px;
      margin-bottom: 15px;
    }

    .save_dialog .save {
      margin-right: 10px;
    }

    .save_dialog .discard_message {
      text-align: right;
    }

    .save_dialog .discard_message a {
      text-decoration: none;
      color: #46a7b0;
    }
  """ + Helpers.createStyles("save", 26 * -26) + Helpers.createStyles("discard", 27 * -26)
  SnapEditor.insertStyles("save", styles)
