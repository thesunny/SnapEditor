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
      @toolbar = new Toolbar(@api)
      @formize(@toolbar.$toolbar)
      @$el.blur(@updateTextarea)
      @insertStyles("snapeditor_form", @css)

    formize: (toolbar) ->
      $toolbar = $(toolbar)
      textareaCoords = @$textarea.getCoordinates()
      toolbarCoords = $toolbar.measure(-> @getCoordinates())
      # Setup the container.
      @$container.css(
        width: textareaCoords.width
        height: textareaCoords.height
      )
      # Add the toolbar.
      @$container.prepend($toolbar.show())
      # Setup the iframe.
      $(@iframe).css(height: textareaCoords.height - toolbarCoords.height)
      # Set the height of the iframe container because if we don't do this, it
      # sticks out a few pixels.
      @$iframeContainer.css(height: textareaCoords.height - toolbarCoords.height)
      # Swap.
      @$textarea.hide()
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

  return FormEditor
