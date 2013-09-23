# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see COPYING and COPYING.LESSER.
define [
  "jquery.custom",
  "config/config.default"
], ($, Defaults) ->
  SnapEditor.Form.config = $.extend({}, SnapEditor.config)
