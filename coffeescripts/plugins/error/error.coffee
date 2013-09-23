# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom"], ($) ->
  SnapEditor.dialogs.error =
    html:
      """
        <div class="error"></div>
        <button class="button okay">#{SnapEditor.lang.ok}</button>
      """

    onSetup: (e) ->
      e.dialog.on(".okay", "click", e.dialog.close)

    # Options:
    # * title - title of the dialog (optional)
    # * error - text or HTML
    onOpen: (e, options = {}) ->
      e.dialog.setTitle(options.title)
      $(e.dialog.find(".error")).html(options.error)
      e.dialog.find(".okay")[0].focus()
