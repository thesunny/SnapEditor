# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom", "core/helpers", "core/editor", "config/config.default.form", "core/assets", "styles/cssreset-min.css", "styles/snapeditor_iframe.css", "core/iframe.snapeditor", "core/toolbar/toolbar.static"], ($, Helpers, Editor, Defaults, Assets, CSSReset, CSS, IFrame, Toolbar) ->
  class FormEditor extends Editor
    constructor: (textarea, config = {}) ->
      # The base editor deals with initializing after document ready. However,
      # the form editor requires the document to be ready as well. Hence, it
      # needs to take care of its own initialization.
      $(Helpers.pass(@formInit, [textarea, config], this))

    formInit: (textarea, config) =>
      # Transform the string into a CSS id selector.
      textarea = "#" + textarea if typeof textarea == "string"
      @$textarea = $(textarea)
      throw "SnapEditor.Form expects a textarea." unless @$textarea.tagName() == "textarea"
      # Ensure stylesheets is an array.
      config.stylesheets = $.makeArray(config.stylesheets)
      @$container = $('<div class="snapeditor_form"/>').hide().insertAfter(@$textarea)
      @$iframeContainer = $('<div class="snapeditor_form_iframe_container"/>').appendTo(@$container)
      # This is here because assets aren't initialized until we call the super
      # constructor. However, we can't call the super constructor before the
      # iframe loads, but we need the assets to create the iframe.
      assets = new Assets(config.path)
      self = this
      @iframe = new IFrame(
        class: "snapeditor_form_iframe"
        contents: @$textarea.attr("value")
        contentClass: config.contentClass || "snapeditor_form_content"
        stylesheets: config.stylesheets
        # Adds default CSS if no stylesheets are given.
        styles: if config.stylesheets.length > 0 then "" else CSSReset + CSS
        load: -> self.finishConstructor.call(self, this.el, config)
      )
      # The frameborder must be set before the iframe is inserted. If it is
      # added afterwards, it has no effect.
      $(@iframe).attr("frameborder", 0).css(
        border: "none"
        width: "100%"
      ).appendTo(@$iframeContainer)

    finishConstructor: (el, config) =>
      FormEditor.__super__.constructor.call(this, el, SnapEditor.Form.config, config)

    # Perform the actual initialization of the editor.
    init: (el) =>
      super(el)
      @toolbar = new Toolbar(@config.toolbar, editor: this)
      @formize(@toolbar.$el)
      @$el.blur(@updateTextarea)
      @insertStyles("snapeditor_form", @css)

    formize: (toolbar) ->
      $toolbar = $(toolbar)
      textareaSize = $.extend(@$textarea.getSize(), x: @config.width, y: @config.height)
      toolbarSize = $toolbar.measure(-> @getSize())
      # Setup the container.
      @$container.css(
        width: textareaSize.x
        height: textareaSize.y
      )
      # Add the toolbar.
      @$container.prepend($toolbar)
      # Setup the iframe.
      $(@iframe).css(height: textareaSize.y - toolbarSize.y)
      # Set the height of the iframe container because if we don't do this, it
      # sticks out a few pixels.
      @$iframeContainer.css(height: textareaSize.y - toolbarSize.y)
      # Swap.
      # Don't hide the textarea. If we hide the textarea, we can't tab into
      # it. Instead, just move it off the page. When the focus is given to the
      # textarea, activate the editor.
      @$textarea.css(
        position: "absolute"
        top: 0
        left: -9999
      ).focus(=> @api.activate())
      @$container.show()

    css: """
      .snapeditor_form_iframe_container {
        border: 1px solid #dddddd;
        border-top: none;
      }
    """

    updateTextarea: =>
      newContents = @getContents()
      unless @oldContents == newContents
        @$textarea.val(newContents)
        @oldContents = newContents

    addCustomDataToEvent: (e) ->
      super(e)
      # If mouse coordinates are set and the target came from inside the
      # iframe, then we need to adjust the outerPage coordinates.
      if e.pageX and Helpers.getDocument(e.target) != document
        coords = Helpers.transformCoordinatesRelativeToOuter(
          x: e.outerPageX
          y: e.outerPageY
          @iframe
        )
        e.outerPageX = coords.x
        e.outerPageY = coords.y

    addIFrameShims: ->
      super(@iframe)

    getCoordinates: (range) ->
      coords = super(range)
      # Make sure the coordinates are relative to the outside document.
      coords.outer = $.extend({}, Helpers.transformCoordinatesRelativeToOuter(coords, @iframe))
      coords
