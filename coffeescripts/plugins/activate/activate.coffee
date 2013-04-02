# This plugin controls how the editor will be activated.
define ["jquery.custom", "core/browser", "core/helpers", "plugins/activate/activate.others", "plugins/activate/activate.ie"], ($, Browser, Helpers, Others, IE) ->
  window.SnapEditor.internalPlugins.activate =
    events:
      pluginsReady: (e) -> e.api.config.plugins.activate.addActivateEvents(e.api)

    # Handles after a click has occurred.
    #
    # NOTE: This should trigger making @api.$el editable.
    click: (api) ->
      api.trigger("snapeditor.activate_click")

    # Activates the editing session.
    activate: (api) ->
      api.activate()
      api.on("snapeditor.deactivate", api.config.plugins.activate.deactivate)

    # Deactivates the editing session.
    deactivate: (e) ->
      api = e.api
      plugin = api.config.plugins.activate
      api.off("snapeditor.deactivate", plugin.deactivate)
      plugin.addActivateEvents(api)

    # True if el is a link or is inside a link. False otherwise.
    #
    # TODO: Determine if this function should be moved. Maybe to Helpers. If it
    # is moved, it should probably be renamed to something more descriptive
    # because it doesn't just check if el is a link. It checks if it is a link
    # or it is inside a link.
    isLink: (el) ->
      $el = $(el)
      $el.tagName() == 'a' or $el.parent('a').length != 0

  Helpers.extend(window.SnapEditor.internalPlugins.activate, if Browser.isIE then IE else Others)
