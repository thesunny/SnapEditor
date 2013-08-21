define ["jquery.custom", "plugins/helpers", "jquery.file_upload"], ($, Helpers) ->
  SnapEditor.dialogs.image =
    title: SnapEditor.lang.imageUploadTitle

    html:
      """
        <div class="snapeditor_image_nav">
          <a class="upload" href="javascript:void(null);">Upload</a>
          <a class="url" href="javascript:void(null);">URL</a>
        </div>
        <div class="snapeditor_image_upload">
          <form class="single_upload"><input type="file"></form>
          <form class="multi_upload"><input type="file" multiple></form>
          <div class="snapeditor_image_upload_progress_container" style="display: none;"></div>
        </div>
        <div class="snapeditor_image_url">
          <form>
            <input type="text">
            <input type="submit" value="Insert">
          </form>
        </div>
      """

    onSetup: (e) ->
      @imageCounter = 0
      @$singleUpload = $(e.dialog.find(".snapeditor_image_upload .single_upload"))
      @$multiUpload = $(e.dialog.find(".snapeditor_image_upload .multi_upload"))
      @$uploadContainer = $(e.dialog.find(".snapeditor_image_upload"))
      @$urlContainer = $(e.dialog.find(".snapeditor_image_url")).hide()
      @$progressContainer = $(e.dialog.find(".snapeditor_image_upload_progress_container"))
      self = this
      e.dialog.on(".snapeditor_image_nav .upload", "snapeditor.click", (ev) ->
        ev.domEvent.preventDefault()
        self.showUpload()
      )
      e.dialog.on(".snapeditor_image_nav .url", "snapeditor.click", (ev) ->
        ev.domEvent.preventDefault()
        self.showURL()
      )
      e.dialog.on(".snapeditor_image_url form", "snapeditor.submit", (ev) ->
        ev.domEvent.preventDefault()
        self.imageCounter = 1
        # TODO: Handle form errors.
        self.insertImage($(e.dialog.find(".snapeditor_image_url input[type=text]")).val())
      )
      for $upload in [@$singleUpload, @$multiUpload]
        $upload.find("input").on("fileuploadstart", (ev, data) ->
          # Hide the input and show the overall progress bar.
          $upload.hide()
          self.$progressContainer.show().append('<div class="progress" style="width: 0%></div>"')
        ).on("fileuploadadd", (ev, data) ->
          # File is added so increment the image count and add a progress bar.
          self.imageCounter += 1
          data.progressBar = $('<div class="progress" style="width: 0%"></div>').appendTo(self.progressContainer)
        ).on("fileuploadprogress", (ev, data) ->
          progress = data.loaded / data.total
          data.progressBar.css("width", "#{parseInt(progress * 100, 10)}%")
        ).on("fileuploadprogressall", (ev, data) ->
          progress = data.loaded / data.total
          $(self.dialog.find(".snapeditor_image_upload_progress_container .progress")[0]).css("width", "#{parseInt(progress * 100, 10)}%")
        ).on("fileuploaddone", (ev, data) ->
          # TODO: Handle errors
          if data.result.status_code == 200
            self.insertImage(data.result.url)
        )

    # Options:
    # imageEl - replaces the imageEl instead of inserting a new image
    # multiple - allow multiple images (defaults to false)
    # onError - function to handle an error
    onOpen: (e, @options) ->
      @api = e.api
      @dialog = e.dialog

      formData = []
      formData.push(name: param, value: value) for own param, value of @api.config.imageServer.uploadParams or {}
      formData.push(name: "directory", value: @api.config.imageServer.directory)

      self = this
      for $upload in [@$singleUpload, @$multiUpload]
        $upload.find("input").fileupload(
          # Server
          url: @api.config.imageServer.uploadUrl
          type: "POST"
          dataType: "json"
          singleFileUploads: true # Separate HTTP requests
          # Params
          paramName: "file"
          formData: formData
          # Resizing
          disableImageResize: /Android(?!.*Chrome)|Opera/.test(window.navigator && navigator.userAgent)
          imageMaxWidth: $(@api.el).getSize().x
        )
      @showUpload()

    onClose: (e) ->
      @$urlContainer.find("form")[0].reset()
      @$progressContainer.empty().hide()

    # Takes the given URL and inserts the image into SnapEditor.
    insertImage: (url) ->
      imageEl = @options.imageEl
      if imageEl
        $(imageEl).attr("src", url)
      else
        id = Math.random().toString(36).substr(2, 16)
        $img = $(@api.createElement("img"))
        $img.attr(id: id, src: url).css("display", "block")
        @api.insert($img[0])
      # Get the width and height
      imgObject = new Image()
      self = this
      imgObject.onload = ->
        # If the width of the image is wider than the editable element itself,
        # shrink the image down to fit.
        elWidth = $(self.api.el).getSize().x
        if @width > elWidth
          width = elWidth
          height = parseInt(@height * (width / @width), 10)
        else
          width = @width
          height = @height
        imageEl or= self.api.find("##{id}")
        $(imageEl).attr(width: width, height: height).removeAttr("id")
        # Decrement the image count and if it is at 0, then we are done.
        # Close the dialog and cleanup.
        self.imageCounter -= 1
        if self.imageCounter == 0
          self.dialog.close()
          self.imageCounter = 0
          self.api.clean()
      imgObject.onerror = @options.onError or ->
      imgObject.src = url

    showUpload: ->
      @$uploadContainer.show()
      @$urlContainer.hide()
      if @options.multiple
        @$singleUpload.hide()
        @$multiUpload.show()
        @$multiUpload.find("input")[0].focus()
      else
        @$singleUpload.show()
        @$multiUpload.hide()
        @$singleUpload.find("input")[0].focus()

    showURL: ->
      @$uploadContainer.hide()
      @$urlContainer.show()
      @$urlContainer.find("input[type=text]")[0].focus()

  SnapEditor.actions.image = (e) ->
    e.api.showDialog("image", e, multiple: true)

  SnapEditor.buttons.image = Helpers.createButton("image", "ctrl+g", onInclude: (e) ->
    e.api.config.behaviours.push("image")
    e.api.addWhitelistRule("Image", "img[src, width, height, style]")
  )

  SnapEditor.behaviours.image =
    click: (e) ->
      if $(e.target).tagName() == "img"
        e.api.showDialog("image", e, imageEl: e.target, mutliple: false)

  styles = """
    .snapeditor_image_upload .progress {
      height: 20px;
      background-color: #0087af;
    }
  """ + Helpers.createStyles("image", 23 * -26)
  styles = Helpers.createStyles("image", 23 * -26)
  SnapEditor.insertStyles("image", styles)
