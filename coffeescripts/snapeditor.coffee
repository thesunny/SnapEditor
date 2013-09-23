# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
# This require is specific to almond.js and not require.js.
# The third argument is the relName. We don't need it so we set it to null.
# The fourth argument is set to true for loading the editor synchronously.
# This is needed so that the SnapEditor object is available immediately.
require ["jquery.custom", "snapeditor.pre", "core/browser", "core/editor.in_place", "core/editor.form", "core/editor.unsupported"], (($, Pre, Browser, InPlaceEditor, FormEditor, UnsupportedEditor) ->
  # NOTE: Most of the SnapEditor stuff is in snapeditor.pre.coffee. This is so
  # that the other modules have access to the SnapEditor object.

  # Save the configs as we'll replace SnapEditor.InPlace and SnapEditor.Form.
  inPlaceConfig = SnapEditor.InPlace.config
  formConfig = SnapEditor.Form.config

  # Check for support.
  InPlaceEditor = FormEditor = UnsupportedEditor unless Browser.isSupported

  # Replace the previous objects.
  SnapEditor.InPlace = InPlaceEditor
  SnapEditor.Form = FormEditor

  # Re-add the configs.
  SnapEditor.InPlace.config = inPlaceConfig
  SnapEditor.Form.config = formConfig
), null, true
