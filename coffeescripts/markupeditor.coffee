# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom", "snapeditor.pre", "core/browser", "core/editor.in_place", "core/editor.form", "core/editor.unsupported", "marked", "unmarked"], (($, Pre, Browser, InPlaceEditor, FormEditor, UnsupportedEditor, marked, unmarked) ->

  # directory = "insecure/123";
  # uploadURL = "/snapimage_api";


  config =
    onGetContentsFromTextarea: (e) ->
      return marked(e)
    # TODO:
    # This needs to convert HTML to markdown
    # onSetTextarea: (e) ->
    #   unmarked = new Unmarked()
    #   return unmarked.toMarkdown(e)
    # TODO:
    # HERE HERE HERE! Adding PRE to the cleaner flubs things up!
    # cleaner:
    #   whitelist:
    #     # PRE
    #     "PRE": "pre"
    # onSave: (e) ->
    #   console.log('SAVE!!!')

    # image:
    #   insertByUpload: true
    #   uploadURL: uploadURL
    #   uploadParams:
    #     directory: directory

  Pre.behaviours.markdownConvert =
    onGetContents: (e) ->
      el = e.api.el
      unmarked = new Unmarked()
      e.contents = unmarked.toMarkdown(el)
    # onGetContentsFromTextarea: (e) ->
    #   console.log('markdownConvert')
    #   console.log(e)
    #   e.contents = marked(e.contents)
    #   e
    # onGetContents: (e) ->
    #   el = e.api.el
    #   unmarked = new Unmarked()
    #   e.contents = unmarked.toMarkdown(el)

  SnapEditor.config.behaviours.push("markdownConvert")
  SnapEditor.config.cleaner.ignore.push("pre")

  # window.Editor = {}
  # window.Editor.markdown = (el, options) ->
  #   new SnapEditor.Form(el, config)


  # Meditor Class Definition Here

  class Meditor
    constructor: (el, @options) ->
      @formEditor = new SnapEditor.Form(el, config)

  window.Meditor = Meditor

  # if window.jQuery
  #   window.jQuery.fn.meditor = (options) ->
  #     new Meditor(this[0], options)

)