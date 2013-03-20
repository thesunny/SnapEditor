# json2 is needed for IE7. IE7 does not implement JSON natively.
# NOTE: json2 does not follow AMD. The J is needed to swallow up the undefined
# given by json2.
define ["../../../lib/json2", "jquery.custom", "core/browser"], (J, $, Browser) ->
  class SingleUploader
    register: (@api) ->
      @options = @api.config["image"]
      @checkOptions()

    checkOptions: ->
      throw "Missing 'image' config" unless @options
      throw "Missing 'url' in image config" unless @options.url
      throw "Missing 'resource_id' in image config" unless @options.resource_id

    getUI: (@ui) ->
      image = @ui.button(action: "insert_image", description: "Insert Image", shortcut: "Ctrl+G", icon: { url: @api.imageAsset("image.png"), width: 24, height: 24, offset: [3, 3] })
      return {
        "toolbar:default": "image"
        image: image
      }

    getActions: ->
      return {
        insert_image: @show
      }

    getKeyboardShortcuts: ->
      return {
        "ctrl.g": "insert_image"
      }

    generateDialog: (ui) ->
      json = JSON.stringify(
        # TODO: Currently, grabbing the el's width is off for the form editor
        # because the el has not been properly formized yet. This is not the
        # correct place for the dialog anyways so ignore for now.
        action: "generate_image"
        resource_identifier: @options.resource_id
        max_width: $(@api.el).getSize().x
        client_security_token: @options.client_security_token
        response_content_type: "text/html"
        response_template: '<script type="text/javascript">response = {{json}}</script>'
      )
      # The form has particular attributes on purpose.
      # enctype - for modern browsers to tell the server that this is a
      #   file upload
      # encoding - for IE7 because it doesn't support enctype
      # accept-charset - for Firefox as it gives a warning without it
      # target - for submitting the form through the iframe
      iframeName = "insert_image_iframe_#{Math.floor(Math.random() * 99999)}"
      @dialog = ui.dialog("Upload New Image",
        """
          <div class="error" style="display: none;"></div>
          <form class="insert_image_form" action="#{@options.url}" method="post" enctype="multipart/form-data" encoding="multipart/form-data" target="#{iframeName}" accept-charset="utf-8">
            <input class="insert_image_json" type="hidden" name="json" value='#{json}' />
            <div class="insert_image_text">Select image to upload:</div>
            <div class="field_container">
              <input class="insert_image_file" type="file" name="file" accept="image/*" />
            </div>
          </form>
          <iframe class="insert_image_iframe" name="#{iframeName}" style="display: none;"></iframe>
        """
      )

    setupDialog: ->
      unless @dialog
        # Generate the dialog here after show(). In IE, when the iframe is not
        # shown yet, it reports the size of @api.el to be 0. Generating the
        # dialog here guarantees that the iframe is already shown and that
        # getting the size will return the correct value.
        @generateDialog(@ui)
        @dialog.on("snapeditor.dialog_hide", @handleDialogHide)
        @$dialog = $(@dialog.getEl())
        @$error = @$dialog.find(".error")
        @$form = @$dialog.find(".insert_image_form")
        @$fileField = @$dialog.find(".insert_image_file").on("change", @submit)
        @$iframe = @$dialog.find(".insert_image_iframe")
        handleResponse = @handleResponse
        @$iframe.load(-> handleResponse(this.contentWindow.response))

    show: =>
      # Save the range.
      @range = @api.getRange()
      @setupDialog()
      # Reset the form.
      @$form[0].reset()
      @$fileField.attr("disabled", false)
      @dialog.show()
      # TODO: Consider sticking this into the dialog when showing.
      # In Firefox, if we don't set the focus on the dialog first, the focus on
      # the file input will not work. This does not effect other browsers so it
      # has been left in.
      @$dialog[0].focus()
      @$fileField[0].focus()

    hide: =>
      @dialog.hide()

    showError: (msg) ->
      @$error.html(msg).show()

    hideError: ->
      @$error.hide().empty()

    isValidExtension: (filename) ->
      parts = filename.split(".")
      return false unless parts.length > 1
      $.inArray(parts.pop().toLowerCase(), ["png", "gif", "jpg", "jpeg"]) != -1

    submit: (e) =>
      value = @$fileField.attr("value")
      if value.length == 0
        @showError("No file selected")
      else if !@isValidExtension(value)
        @showError("Only .png, .gif, .jpg, or .jpeg are allowed")
      else
        @hideError()
        @$form.submit()
        @$fileField.attr("disabled", true)

    handleResponse: (response) =>
      if response
        @$fileField.attr("disabled", false)
        if response.status_code == 200
          @hide()
          @insertImage(response.image_url, response.image_width, response.image_height)
        else
          @showError(response.message)

    insertImage: (url, width, height) ->
      $img = $(@api.createElement("img"))
      $img.attr(id: "SNAPEDITOR_INSERTED_IMAGE", src: url, width: width, height: height)
      @range.insert($img[0])
      $img = $(@api.find("#SNAPEDITOR_INSERTED_IMAGE")).removeAttr("id")
      @api.select($img[0])
      @update()

    handleDialogHide: =>
      # TODO: May want to move this to the dialog instead.
      # In Firefox, we have to manually move the focus back to the editor. All
      # other browsers do this automatically.
      # In Webkit, the focus is set back to the editor for typing, but the
      # keyboard shortcuts don't work unless we manually move the focus back to
      # the editor.
      # This does not effect IEs so it is left in for consistency.
      @api.el.focus()
      @range.select()

    update: ->
      # In Webkit, after the toolbar is clicked, the focus hops to the parent
      # window. We need to refocus it back into the iframe. Focusing breaks IE
      # and kills the range so the focus is only for Webkit. It does not affect
      # Firefox.
      @api.win.focus() if Browser.isWebkit
      @api.clean()

  return SingleUploader
