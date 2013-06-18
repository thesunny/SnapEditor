define [
  "jquery.custom",
  "config/config.default"
], ($, Defaults) ->
  SnapEditor.Form.config = $.extend({
    activateByLinks: true
  }, SnapEditor.config)
