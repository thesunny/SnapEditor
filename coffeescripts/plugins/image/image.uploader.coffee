# json2 is needed for IE7. IE7 does not implement JSON natively.
# NOTE: json2 does not follow AMD. The J is needed to swallow up the undefined
# given by json2.
define ["../../../lib/json2", "jquery.custom", "../../../lib/swfupload", "core/browser", "core/helpers"], (J, $, SWFUpload, Browser, Helpers) ->
  class Uploader
    register: (@api) ->
      @options = @api.config["image"]
      @checkOptions()

    checkOptions: ->
      throw "Missing 'image' config" unless @options
      throw "Missing 'url' in image config" unless @options.url
      throw "Missing 'resource_id' in image config" unless @options.resource_id

    getUI: (@ui) ->
      image = @ui.button(action: "insert_image", description: "Insert Image", shortcut: "Ctrl+G", icon: { url: @api.assets.image("image.png"), width: 24, height: 24, offset: [3, 3] })
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

    setupDialog: ->
      unless @dialog
        # Generate the dialog here after show(). In IE, when the iframe is not
        # shown yet, it reports the size of @api.el to be 0. Generating the
        # dialog here guarantees that the iframe is already shown and that
        # getting the size will return the correct value.
        @dialog = @ui.dialog("Upload New Image", "<span></span>")
        @dialog.on("hide.dialog", @handleDialogHide)
        @$dialog = $(@dialog.getEl())
        @$placeHolder = @$dialog.find("span")
        json = JSON.stringify(
          # TODO: Currently, grabbing the el's width is off for the form editor
          # because the el has not been properly formized yet. This is not the
          # correct place for the dialog anyways so ignore for now.
          action: "generate_image"
          resource_identifier: @options.resource_id
          max_width: $(@api.el).getSize().x
          client_security_token: @options.client_security_token
        )
        @swfupload = new SWFUpload(
          upload_url: @options.url
          flash_url: @api.assets.flash("swfupload.swf")
          file_post_name: "file"
          post_params: json: json

          file_types: "*.png;*.jpg;*.jpeg;*.gif"
          file_types_description: "Image Files"
          #file_size_limit: 1024 # I'm guessing this is in bytes. Will need to double-check
          #file_upload_limit: 10
          #file_queue_limit: 2

          button_placeholder: @$placeHolder[0]
          button_image_url: @api.assets.image("select_images_sprite.png")
          button_width: 105
          button_height: 28

          #swfupload_loaded_handler: -> console.log "LOADED"
          #file_dialog_start_handler: -> console.log "DIALOG START"
          #file_queued_handler: -> console.log "QUEUED"
          #file_queue_error_handler: -> console.log "QUEUE ERROR"
          file_dialog_complete_handler: @fileDialogCompleteHandler
          #upload_start_handler: -> console.log "UPLOAD START"
          #upload_progress_handler: -> console.log "UPLOAD PROGRESS"
          #upload_error_handler: -> console.log "UPLOAD ERROR"
          upload_success_handler: @uploadSuccessHandler
          upload_complete_handler: @uploadCompleteHandler
        )

    fileDialogCompleteHandler: =>
      # Start uploading the first file in the queue.
      @swfupload.startUpload()

    uploadSuccessHandler: (file, data, response) =>
      @handleResponse(JSON.parse(data))

    uploadCompleteHandler: =>
      if @swfupload.getStats().files_queued > 0
        # Start uploading the next file in the queue if available.
        @swfupload.startUpload()
      else
        # Finished uploading.
        @hide()
        @update() if @uploadedImages.length > 0

    show: =>
      # Save the range.
      @range = @api.range()
      @uploadedImages = []
      @setupDialog()
      @dialog.show()
      # TODO: Consider sticking this into the dialog when showing.
      # In Firefox, if we don't set the focus on the dialog first, the focus on
      # the file input will not work. This does not effect other browsers so it
      # has been left in.
      @$dialog[0].focus()

    hide: =>
      @dialog.hide()

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

    # TODO: Handle errors
    handleResponse: (response) =>
      if response.status_code == 200
        @insertImage(response.image_url, response.image_width, response.image_height)

    insertImage: (url, width, height) ->
      $img = $(@api.createElement("img"))
      $img.attr(id: "SNAPEDITOR_INSERTED_IMAGE", src: url, width: width, height: height)
      @range.paste($img[0])
      $img = $(@api.find("#SNAPEDITOR_INSERTED_IMAGE")).removeAttr("id")
      @uploadedImages.push($img)

    update: ->
      # In Webkit, after the toolbar is clicked, the focus hops to the parent
      # window. We need to refocus it back into the iframe. Focusing breaks IE
      # and kills the range so the focus is only for Webkit. It does not affect
      # Firefox.
      @api.win.focus() if Browser.isWebkit
      @api.clean()
      @api.update()

  return Uploader
