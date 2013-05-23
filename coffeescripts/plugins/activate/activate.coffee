# This plugin controls how the editor will be activated.
define ["jquery.custom", "core/browser", "core/helpers", "plugins/activate/activate.others", "plugins/activate/activate.ie"], ($, Browser, Helpers, Others, IE) ->
  activate =
    # Handles after a click has occurred.
    #
    # NOTE: This should trigger making @api.$el editable.
    click: (api) ->
      api.trigger("snapeditor.activate_click")

    # Activates the editing session.
    activate: (api) ->
      api.activate()
      self = this
      @deactivateHandler = (e) -> self.deactivate(api)
      api.on("snapeditor.deactivate", @deactivateHandler)

    # Deactivates the editing session.
    deactivate: (api) ->
      api.off("snapeditor.deactivate", @deactivateHandler)
      @addActivateEvents(api)

    # True if el is a link or is inside a link. False otherwise.
    #
    # TODO: Determine if this function should be moved. Maybe to Helpers. If it
    # is moved, it should probably be renamed to something more descriptive
    # because it doesn't just check if el is a link. It checks if it is a link
    # or it is inside a link.
    isLink: (el) ->
      $el = $(el)
      $el.tagName() == 'a' or $el.parent('a').length != 0

  SnapEditor.behaviours.activate =
    onPluginsReady: (e) -> activate.addActivateEvents(e.api)

  Helpers.extend(activate, if Browser.isIE then IE else Others)

  # activate returned for testing purposes.
  return activate
