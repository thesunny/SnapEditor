define [
  "jquery.custom",
  "config/config.default"
], ($, Defaults) ->
  SnapEditor.Form.config = $.extend({}, SnapEditor.config)
