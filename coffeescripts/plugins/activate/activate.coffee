# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
# This plugin controls how the editor will be activated.
define ["jquery.custom", "core/browser", "core/helpers", "plugins/activate/activate.others", "plugins/activate/activate.ie"], ($, Browser, Helpers, Others, IE) ->
  activate =
    click: (e, api) ->
      if @shouldActivate(api, e.target)
        e.preventDefault()
      else
        self = this
        $(api.el).one("click", (e) -> self.click(e, api))

    # Activates the editing session.
    finishActivate: (api) ->
      # Ensure that something is selected. This is mainly for IE8.
      unless api.isValid()
        api.selectElementContents(api.el)
        api.collapse(true)
      api.trigger("snapeditor.before_activate")
      api.trigger("snapeditor.activate")
      api.trigger("snapeditor.ready")
      self = this
      @deactivateHandler = (e) -> self.deactivate(api)
      api.on("snapeditor.deactivate", @deactivateHandler)

    # Prepares for handling activation.
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

    shouldActivate: (api, el) ->
      api.isEnabled() and (api.config.activateByLinks or !@isLink(el))

  SnapEditor.actions.activate = (e) ->
    api = e.api
    # This is required for all browsers. A range must be set before kicking
    # off the mousedown/mouseup.
    api.selectElementContents(api.el)
    api.collapse(true)
    $(api.el).trigger("mousedown")
    $(api.el).trigger("mouseup")
    # In Webkit, without focus(), activating inside an iframe doesn't work.
    # Both win.focus() and el.focus() work in Webkit.
    # In Gecko, without focus() activating doesn't work in any scenario.
    # win.focus() does not work but win.el() does in Gecko.
    # Hence, the solution is to use el.focus().
    # Note that calling focus() earlier doesn't work either. It must be after
    # the mouseup call.
    api.el.focus()

  SnapEditor.behaviours.activate =
    onPluginsReady: (e) -> activate.addActivateEvents(e.api)

  Helpers.extend(activate, if Browser.isIE then IE else Others)

  # activate returned for testing purposes.
  return activate
