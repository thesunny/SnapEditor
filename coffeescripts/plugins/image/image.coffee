define ["jquery.custom", "plugins/helpers", "core/browser", "jquery.file_upload"], ($, Helpers, Browser) ->
  SnapEditor.dialogs.image =
    title: SnapEditor.lang.imageUploadTitle

    html:
      """
        <div class="snapeditor_image_nav">
          <a class="upload" href="javascript:void(null);">Upload</a>
          <a class="url" href="javascript:void(null);">URL</a>
        </div>
        <div class="snapeditor_image_upload">
          <input class="single_upload" type="file">
          <input class="multi_upload" type="file" multiple>
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
      @dialog = e.dialog
      @imageCounter = 0
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
      for $upload in [$(@getSingleUpload()), $(@getMultiUpload())]
        $upload.on("fileuploadstart", (ev, data) ->
          # In IE8/9, jQuery File Upload uses iframe transport to upload the
          # images. This causes some issues afterwards when trying to reselect
          # the range. I'm not sure exactly what's going on, but I think it
          # has to do with focusing. The range is still completely valid and
          # we can insert and collapse and move the range around. The only
          # thing we can't do with the range is select it. This makes me think
          # that it has to do with focusing. Adding an image through the URL
          # does not cause this problem because there is no iframe transport.
          # Solutions tried but failed:
          # - tried api.win.focus() but fails in IE9 (works for IE8)
          # - tried api.el.focus() but makes the window jump in IE9 (works for
          #   IE8)
          # - tried placing api.select() in #onOpen() but fails as I think
          #   it's too early
          # - tried placing api.select() in "fileuploadadd" and it works, but
          #   "fileuploadstart" is earlier and called only once
          # - tried placing api.select() in "fileuploadprogress",
          #   "fileuploadprogressall", and "fileuploaddone" but they all fail
          #   as I think it's too late
          # - tried placing api.select() in #insertImage() but it fails as I
          #   think it's too late
          self.api.select() if Browser.isIE8 or Browser.isIE9

          # Hide the input and show the overall progress bar.
          $(self.getSingleUpload()).hide()
          $(self.getMultiUpload()).hide()
          console.log("UPLOADSTART")
          self.$progressContainer.show().append('<div class="progress" style="width: 0%"></div>')
        ).on("fileuploadadd", (ev, data) ->
          # File is added so increment the image count and add a progress bar.
          self.imageCounter += 1
          #data.progressBar = $('<div class="progress" style="width: 0%"></div>').appendTo(self.progressContainer)
        ).on("fileuploadprogress", (ev, data) ->
          #progress = data.loaded / data.total
          #console.log "PROGRESS", progress
          #data.progressBar.css("width", "#{parseInt(progress * 100, 10)}%")
        ).on("fileuploadprogressall", (ev, data) ->
          progress = data.loaded / data.total
          console.log "PROGRESSALL", progress
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

      formData = []
      formData.push(name: param, value: value) for own param, value of @api.config.imageServer.uploadParams or {}

      self = this
      for $upload in [$(@getSingleUpload()), $(@getMultiUpload())]
        $upload.fileupload(
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

    getSingleUpload: ->
      @dialog.find(".snapeditor_image_upload .single_upload")

    getMultiUpload: ->
      @dialog.find(".snapeditor_image_upload .multi_upload")

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
      $singleUpload = $(@getSingleUpload())
      $multiUpload = $(@getMultiUpload())
      if @options.multiple
        $singleUpload.hide()
        $multiUpload.show()
        $multiUpload[0].focus()
      else
        $singleUpload.show()
        $multiUpload.hide()
        $singleUpload[0].focus()

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
  SnapEditor.insertStyles("image", styles)
