define ["jquery.custom", "plugins/helpers", "core/browser", "plugins/link/link.dialog"], ($, Helpers, Browser, Dialog) ->
  window.SnapEditor.internalPlugins.link =
    commands:
      link: Helpers.createCommand("link", "ctrl.k", (e) -> e.api.config.plugins.link.showDialog(e.api))
    showDialog: (api) ->
      if api.isValid()
        @dialog or= new Dialog()
        @dialog.show(api)

  styles = """
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
  """ + Helpers.createStyles("link", 21 * -26)
  window.SnapEditor.insertStyles("link", styles)
