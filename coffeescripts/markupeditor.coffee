# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.


define ["jquery.custom", "snapeditor.pre", "core/browser", "core/editor.in_place", "core/editor.form", "core/editor.unsupported", "marked"], (($, Pre, Browser, InPlaceEditor, FormEditor, UnsupportedEditor, marked) ->

  # directory = "insecure/123";
  # uploadURL = "/snapimage_api";


  $.fn.meditor = (el, options) ->
    $el = $(el)
    markup = $el.val()
    $el.after(markup)

  config =
    onGetTextarea: (e) ->
      return marked(e)
    # TODO:
    # This needs to convert HTML to markdown
    onSetTextarea: (e) ->
      return e
    cleaner:
      whitelist:
        # PRE
        "PRE": "pre"
    onSave: (e) ->
      console.log('SAVE!!!')

    # image:
    #   insertByUpload: true
    #   uploadURL: uploadURL
    #   uploadParams:
    #     directory: directory


  class Meditor
    constructor: (el, @options) ->
      @formEditor = new FormEditor(el, config)

  window.Meditor = Meditor

)