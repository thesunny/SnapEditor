define ["jquery.custom", "core/helpers", "plugins/save/save.prompt_dialog", "plugins/save/save.error_dialog"], ($, Helpers, PromptDialog, ErrorDialog) ->
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
          @getPromptDialog().show(@api)
      else
        @api.deactivate()

    #
    # DIALOGS
    #

    getPromptDialog: ->
      unless @promptDialog
        @promptDialog = new PromptDialog()
        @promptDialog.on(
          save: (e) -> save.save()
          discard: (e) -> save.discard()
        )
      @promptDialog

    getErrorDialog: ->
      @errorDialog or= new ErrorDialog()

    #
    # DIALOG EVENT HANDLERS
    #

    save: ->
      result = "onSave config was never defined."
      result = @api.config.onSave(api: @api) if @api.config.onSave
      result
      if typeof result == "string"
        @getErrorDialog().show(@api, result)
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
    onTryDeactivate: (e) -> save.exit() if e.api.config.onSave
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
