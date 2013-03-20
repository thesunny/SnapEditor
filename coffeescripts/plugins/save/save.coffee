define ["jquery.custom", "core/browser", "core/helpers", "plugins/save/save.prompt_dialog", "plugins/save/save.error_dialog"], ($, Browser, Helpers, PromptDialog, ErrorDialog) ->
  window.SnapEditor.internalPlugins.save =
    events:
      activate: (e) -> e.api.disableImmediateDeactivate() if e.api.config.onSave
      ready: (e) -> e.api.config.plugins.save.activate(e.api) if e.api.config.onSave
      tryDeactivate: (e) -> e.api.config.plugins.save.exit(e.api) if e.api.config.onSave
      deactivate: (e) -> e.api.config.plugins.save.deactivate(e.api) if e.api.config.onSave

    commands:
      save: Helpers.createCommand("save", "ctrl.s", (e) -> e.api.config.plugins.save.save(e.api))
      # TODO: In Chrome, when an element is contenteditable, the esc keydown
      # event does not get triggered. However, the esc keyup event does
      # trigger. Unfortunately, the target is the body and not the element
      # itself. Removing the shortcut until a solution can be found.
      exit: Helpers.createCommand("exit", "", (e) -> e.api.config.plugins.save.exit(e.api))

    #
    # PLUGIN EVENT HANDLERS
    #

    activate: (api) ->
      @setOriginalHTML(api)
      $(window).on("beforeunload", api: api, @leavePage)

    deactivate: (api) ->
      @unsetOriginalHTML()
      $(window).off("beforeunload", @leavePage)

    leavePage: (e) ->
      api = e.data.api
      return api.config.lang.saveLeavePageMessage if api.config.plugins.save.isEdited(api)
      # Force an empty return because IE requires an empty return in order to
      # not show a dialog. If you return true or null, a dialog still shows.
      # An empty return does not affect other browsers.
      return

    exit: (api) ->
      plugin = api.config.plugins.save
      if plugin.isEdited(api)
        plugin.getPromptDialog().show(api)
      else
        api.deactivate()

    #
    # DIALOGS
    #

    getPromptDialog: ->
      unless @promptDialog
        @promptDialog = new PromptDialog()
        @promptDialog.on(
          save: (e) -> e.api.config.plugins.save.save(e.api)
          resume: (e) -> e.api.config.plugins.save.resume(e.api)
          discard: (e) -> e.api.config.plugins.save.discard(e.api)
        )
      @promptDialog

    getErrorDialog: ->
      @errorDialog or= new ErrorDialog()

    #
    # DIALOG EVENT HANDLERS
    #

    save: (api) ->
      plugin = api.config.plugins.save
      result = api.save()
      if typeof result == "string"
        plugin.getErrorDialog().show(api, result)
      else
        api.deactivate()
      plugin.getPromptDialog().hide()

    resume: (api) ->
      api.config.plugins.save.getPromptDialog().hide()

    discard: (api) ->
      plugin = api.config.plugins.save
      plugin.getPromptDialog().hide()
      api.setContents(plugin.originalHTML)
      api.deactivate()

    #
    # FUNCTIONS
    #

    setOriginalHTML: (api) ->
      @originalHTML = api.getContents()

    unsetOriginalHTML: ->
      @originalHTML = null

    isEdited: (api) ->
      api.getContents() != @originalHTML

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
  """ + Helpers.createStyles("save", 26 * -26) + Helpers.createStyles("exit", 27 * -26)
  window.SnapEditor.insertStyles("save", styles)
