# json2 is needed for IE7. IE7 does not implement JSON natively.
# NOTE: json2 does not follow AMD. The J is needed to swallow up the undefined
# given by json2.
define ["../../../lib/json2", "jquery.custom", "../../../lib/SnapImage", "core/browser", "core/helpers"], (J, $, SnapImage, Browser, Helpers) ->
  class Uploader
    register: (@api) ->
      @options = @api.config["imageServer"]

    checkOptions: ->
      throw "Missing 'imageServer' config" unless @options
      throw "Missing 'uploadUrl' in image config" unless @options.uploadUrl
      throw "Missing 'publicUrl' in image config" unless @options.publicUrl
      throw "Missing 'directory' in image config" unless @options.directory

    getUI: (@ui) ->
      image = @ui.button(action: "insert_image", description: @api.lang.image, shortcut: "Ctrl+G", icon: { url: @api.assets.image("image.png"), width: 24, height: 24, offset: [3, 3] })
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
        @options.uploadParams ||= {}
        @options.uploadParams.directory = @options.directory
        # Generate the dialog here after show(). In IE, when the iframe is not
        # shown yet, it reports the size of @api.el to be 0. Generating the
        # dialog here guarantees that the iframe is already shown and that
        # getting the size will return the correct value.
        placeholderId = "image_upload_button_#{Math.floor(Math.random()*99999)}"
        @dialog = @ui.dialog(@api.lang.imageUploadTitle, "<span id=\"#{placeholderId}\"></span>")
        @dialog.on("snapeditor.dialog.hide", @handleDialogHide)
        @$dialog = $(@dialog.getEl())
        @snapImage = new SnapImage(
          flashUrl: @api.assets.flash("SnapImage.swf")
          uploadUrl: @options.uploadUrl
          # uploadName: "file"
          uploadParams: @options.uploadParams
          # resizeParams: {}
          # fileTypes: "*.jpg;*.jpeg;*.gif;*.png"
          # fileTypesDescription: "Images"

          fileSizeLimit: @options.fileSizeLimit || 10485760 # 10MB
          # TODO: Currently, grabbing the el's width is off for the form editor
          # because the el has not been properly formized yet. This is not the
          # correct place for the dialog anyways so ignore for now.
          maxImageWidth: $(@api.el).getSize().x
          # maxImageHeight: 2096

          buttonPlaceholderId: placeholderId
          buttonImageUrl: @api.assets.image("select_images.png")
          buttonWidth: 105
          buttonHeight: 28
          buttonText: @api.lang.image
          buttonTextStyle: "color: #FFFFFF; font-size: 12px; text-align: center;"
          buttonTextPaddingTop: 6
          # buttonTextPaddingLeft: 12

          filenameGenerator: @filenameGenerator
          onUploadSuccess: @uploadSuccessHandler
          onUploadsComplete: @uploadsCompleteHandler
          # debug: true
        )

    filenameGenerator: (args) ->
      base = Math.random().toString(36).substr(2, 16)
      "#{base}-#{args.width}x#{args.height}.#{args.ext}"

    uploadSuccessHandler: (serverData, imageData) =>
      @handleResponse(JSON.parse(serverData), imageData)

    uploadsCompleteHandler: =>
      @hide()
      @update()

    show: =>
      # Checking of options was moved down here for now because we don't want
      # it checking the options unless it is actually used.
      @checkOptions()
      # Save the range.
      @range = @api.getRange()
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
    handleResponse: (serverData, imageData) =>
      if serverData.status_code == 200
        @insertImage("#{@options.publicUrl}/#{@options.directory}/#{imageData.filename}", imageData.width, imageData.height)

    insertImage: (url, width, height) ->
      $img = $(@api.createElement("img"))
      $img.attr(id: "SNAPEDITOR_INSERTED_IMAGE", src: url, width: width, height: height)
      @range.insert($img[0])
      $img = $(@api.find("#SNAPEDITOR_INSERTED_IMAGE")).removeAttr("id")
      @uploadedImages.push($img)

    update: ->
      # In Webkit, after the toolbar is clicked, the focus hops to the parent
      # window. We need to refocus it back into the iframe. Focusing breaks IE
      # and kills the range so the focus is only for Webkit. It does not affect
      # Firefox.
      @api.win.focus() if Browser.isWebkit
      @api.clean()

  return Uploader
