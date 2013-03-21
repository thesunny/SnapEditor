# json2 is needed for IE7. IE7 does not implement JSON natively.
# NOTE: json2 does not follow AMD. The J is needed to swallow up the undefined
# given by json2.
define ["../../../lib/json2", "jquery.custom", "../../../lib/SnapImage", "core/ui/ui.dialog"], (J, $, SnapImage, Dialog) ->
  class UploadDialog extends Dialog
    # Options:
    # * uploadParams
    # * directory
    # * uploadUrl
    # * uploadParams
    # * fileSizeLimit
    # * publicUrl
    constructor: (@options = {}) ->
      @checkOptions()
      @placeholderId = "image_upload_button_#{Math.floor(Math.random()*99999)}"
      super()

    checkOptions: ->
      throw "Missing 'imageServer' config" unless @options
      throw "Missing 'uploadUrl' in image config" unless @options.uploadUrl
      throw "Missing 'publicUrl' in image config" unless @options.publicUrl
      throw "Missing 'directory' in image config" unless @options.directory

    getHTML: ->
      "<span id=\"#{@placeholderId}\"></span>"

    setup: ->
      unless @$el
        super(title: @api.config.lang.imageUploadTitle, html: @getHTML())
        @options.uploadParams ||= {}
        @options.uploadParams.directory = @options.directory
        @snapImage = new SnapImage(
          flashUrl: @api.flashAsset("SnapImage.swf")
          uploadUrl: @options.uploadUrl
          # uploadName: "file"
          uploadParams: @options.uploadParams
          # resizeParams: {}
          # fileTypes: "*.jpg;*.jpeg;*.gif;*.png"
          # fileTypesDescription: "Images"

          fileSizeLimit: @options.fileSizeLimit || 10485760 # 10MB
          maxImageWidth: $(@api.el).getSize().x
          # maxImageHeight: 2096

          buttonPlaceholderId: @placeholderId
          buttonImageUrl: @api.imageAsset("select_images.png")
          buttonWidth: 105
          buttonHeight: 28
          buttonText: @api.config.lang.image
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
      @api.clean()

    show: (api) =>
      super(api)
      # Save the range.
      @range = @api.getRange()
      @uploadedImages = []

    hide: =>
      super()
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
