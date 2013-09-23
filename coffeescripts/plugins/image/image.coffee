# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom", "plugins/helpers", "core/browser", "core/dialog/tabs", "jquery.file_upload"], ($, Helpers, Browser, Tabs) ->
  uploader =
    title: SnapEditor.lang.imageUpload

    html:
      """
        <div class="snapeditor_image_upload">
          <input class="single_upload" type="file">
          <input class="multi_upload" type="file" multiple>
          <div class="snapeditor_image_buttons">
            <a class="button cancel" href="javascript:void(null);">#{SnapEditor.lang.cancel}</a>
          </div>
        </div>
      """

    getContentEl: (@api) ->
      self = this

      unless @$contentEl
        @$contentEl = $(@html).on("show", ->
          $singleUpload = $(self.getSingleUpload())
          $multiUpload = $(self.getMultiUpload())
          if image.options.multiple
            $singleUpload.hide()
            $multiUpload.show()
            $multiUpload[0].focus()
          else
            $singleUpload.show()
            $multiUpload.hide()
            $singleUpload[0].focus()
        )

        # Buttons.
        @$buttonsContainer = @$contentEl.find(".snapeditor_image_buttons")
        @$contentEl.find(".cancel").click(-> self.api.closeDialog("image"))

        # Setup the uploads.
        $.each([@getSingleUpload(), @getMultiUpload()], ->
          image.setupUploader($(this))
        )

      image.configUploader($upload) for $upload in [$(@getSingleUpload()), $(@getMultiUpload())]

      @$contentEl

    getSingleUpload: ->
      @$contentEl.find(".single_upload")

    getMultiUpload: ->
      @$contentEl.find(".multi_upload")

  urlLoader =
    title: SnapEditor.lang.imageURL

    html:
      """
        <div class="snapeditor_image_url">
          <form>
            <div>#{SnapEditor.lang.url}</div>
            <input type="text">
            <div class="snapeditor_image_buttons">
              <input class="button submit" type="submit" value="#{SnapEditor.lang.insert}">
              <a class="button cancel" href="javascript:void(null);">#{SnapEditor.lang.cancel}</a>
            </div>
          </form>
        </div>
      """

    getContentEl: (@api) ->
      unless @$contentEl
        self = this
        @$contentEl = $(@html).on("show", ->
          $(this).find("form")[0].reset()
          $(this).find("input[type=text]")[0].focus()
        )
        @$contentEl.find(".cancel").click(-> self.api.closeDialog("image"))
        @$contentEl.find("form").on("submit", (e) ->
          e.preventDefault()
          url = $.trim(self.$contentEl.find("input[type=text]").val())
          if url.length > 0
            image.imageCounter = 1
            # Load the image. If it loads, then insert it.
            imgObject = new Image()
            imgObject.onload = ->
              image.insertImage(url, image.options.imageEl)
            imgObject.onerror = ->
              image.errors.push("#{url}: Cannot be loaded or is not an image")
              image.finish()
            imgObject.src = url
        )

      @$contentEl

  SnapEditor.dialogs.image =
    title: SnapEditor.lang.imageInsertTitle

    html:
      """
        <div class="snapeditor_image">
          <div class="snapeditor_image_container"></div>
        </div>
      """

    onSetup: (e) ->
      @dialog = e.dialog
      @tabs = new Tabs(
        tabsClassname: "snapeditor_image_tabs"
        tabClassname: "snapeditor_image_tab"
        contentClassname: "snapeditor_image_tabs_content"
      )

    # Options:
    # * imageEl - replaces the imageEl instead of inserting a new image
    # * multiple - allow multiple images (defaults to false)
    onOpen: (e, options) ->
      image.options = options
      @tabs.clear()
      @tabs.add(uploader.getContentEl(e.api), uploader.title) if e.api.config.image.insertByUpload
      @tabs.add(urlLoader.getContentEl(e.api), urlLoader.title) if e.api.config.image.insertByURL
      @tabs.insert(@dialog.find(".snapeditor_image_container"))

  SnapEditor.dialogs.imageUploadProgress =
    title: SnapEditor.lang.imageInsertTitle

    html:
      """
        <div class="snapeditor_progress">
          <div class="bar"></div>
        </div>
      """

    onSetup: (e) ->
      @dialog = e.dialog
      @$progressBar = $(@dialog.find(".bar"))

    onOpen: (e, @$upload) ->
      @$progressBar.css("width", "5%")

    update: (loaded, total) ->
      progress = loaded / total
      @$progressBar.css("width", "#{parseInt(progress * 100, 10)}%")

  SnapEditor.actions.image = (e) ->
    if e.api.getParentElement("table, ul, ol")
      alert("Sorry. This action cannot be performed inside a table or list.")
    else
      e.api.openDialog("image", e, multiple: true)

  SnapEditor.buttons.image = Helpers.createButton("image", "ctrl+g", onInclude: (e) ->
    e.api.config.behaviours.push("image")
    e.api.addWhitelistRule("Image", "img[src, width, height, style]")
  )

  image =
    options: {}
    api: null
    imageCounter: 0
    errors: []

    prepareConfig: ->
      @api.config.image or= {}
      @api.config.image.insertByURL = true if typeof @api.config.image.insertByURL == "undefined"
      if @api.config.image.insertByUpload
        throw "Missing image config: uploadURL" unless @api.config.image.uploadURL

    setupUploader: ($upload) ->
      self = this
      $upload.on("fileuploadstart", (e, data) ->
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

        self.api.closeDialog("image")
        self.api.openDialog("imageUploadProgress", api: self.api)
      ).on("fileuploadadd", (e, data) ->
        unless data.files[0].name
          file = data.files[0]
          extname = file.type.replace("image/", "")
          data.files[0].name = "pasted_image.#{extname}"
        # File is added so increment the image count.
        self.imageCounter += 1
      ).on("fileuploadprogressall", (e, data) ->
          SnapEditor.dialogs.imageUploadProgress.update(data.loaded, data.total)
      ).on("fileuploaddone", (e, data) ->
        if data.result.status_code == 200
          self.insertImage(data.result.url, self.options.imageEl)
        else
          self.errors.push("#{data.files[0].name}: #{data.result.message}")
          self.finish()
      ).on("fileuploadfail", (e, data) ->
        self.errors.push("#{data.files[0].name}: #{data.errorThrown}")
        self.finish()
      )

    configUploader: ($upload, options = {}) ->
      # Setup the form data.
      formData = [{ name: "max_width", value: $(@api.el).getSize().x }]
      formData.push(name: param, value: value) for own param, value of @api.config.image.uploadParams or {}

      $upload.fileupload($.extend(
        # Server
        url: @api.config.image.uploadURL
        type: "POST"
        dataType: "json"
        singleFileUploads: true # Separate HTTP requests
        # Params
        paramName: "file"
        formData: formData
        # Resizing
        disableImageResize: /Android(?!.*Chrome)|Opera/.test(window.navigator && navigator.userAgent)
        imageMaxWidth: $(@api.el).getSize().x
        # If dropZone is not set to null, when another uploader sets the
        # dropZone, any uploaders that didn't set dropZone to null will use
        # the set dropZone. The same thing happens with pasteZone.
        # This doesn't seem right and could be a bug in the
        # jQuery plugin.
        dropZone: null
        pasteZone: null
        options
      ))

    getAutoUploader: ->
      unless @$autoUploader
        @$autoUploader = $("<input/>").
          attr(
            type: "file"
            multiple: true
          ).
          css(
            position: "absolute"
            top: 0
            left: -9999
          ).
          appendTo("body")
        @setupUploader(@$autoUploader)
      @$autoUploader

    preventDefault: (e) ->
      e.preventDefault()

    enableAutoUploader: ->
      if @api.config.image.insertByUpload
        $(@api.doc).on("drop dragover", @preventDefault)
        $upload = @getAutoUploader()
        @configUploader($upload,
          dropZone: @api.el
          pasteZone: @api.el
        )

    disableAutoUploader: ->
      if @api.config.image.insertByUpload
        $(@api.doc).off("drop dragover", @preventDefault)
        @getAutoUploader().fileupload("option",
          dropZone: null
          pasteZone: null
        )

    # Takes the given URL and inserts the image into SnapEditor.
    insertImage: (url, imageEl) ->
      if imageEl
        $(imageEl).attr("src", url)
      else
        id = Math.random().toString(36).substr(2, 16)
        $img = $(@api.createElement("img"))
        $img.attr(id: id, src: url)
        @api.insert($img[0])
      # Get the width and height.
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
        self.finish()
      imgObject.onerror = ->
        image.errors.push("#{url}: Cannot be loaded or is not an image")
        image.finish()
      imgObject.src = url

    onErrors: (errors) ->
      html = "<p>The following errors occurred:</p><ul>"
      html += "<li>#{error}</li>" for error in errors
      html += "</ul>"
      @api.openDialog("error", { api: @api }, { title: SnapEditor.lang.imageErrorTitle, error: html })

    finish: ->
      # Decrement the image count and if it is at 0, then we are done.
      # Close the dialog and cleanup.
      @imageCounter -= 1
      if @imageCounter == 0
        @api.closeDialog("image")
        @api.closeDialog("imageUploadProgress")
        @hideShim()
        # In IE8, after inserting an image using a URL, the iframe jumps to
        # the top. This is caused by cleaning the entire editable element.
        # If we just call api.clean(), the jumping does not occur. However,
        # we need to clean the entire editable element. Hence, we call
        # api.keepRange(). Note that the jumping doesn't happen after an
        # upload. It is only after a URL.
        if Browser.isIE8
          self = this
          @api.keepRange(->
            self.api.clean(self.api.el.childNodes[0], self.api.el.childNodes[self.api.el.childNodes.length - 1])
          )
        else
          @api.clean(@api.el.childNodes[0], @api.el.childNodes[@api.el.childNodes.length - 1])
        # Handle any errors.
        if @errors.length > 0
          if @api.config.image.onErrors
            @api.config.image.onErrors(@errors)
          else
            @onErrors(@errors)
        # Cleanup.
        @options = {}
        @imageCounter = 0
        @errors = []

    getShim: (styles) ->
      $shim = $(@api.doc).find(".snapeditor_image_shim")
      if $shim.length == 0
        # One of the original problems with the shim was setting the
        # transparency on the background but keeping the children opaque.
        # Opaciy and filter caused the children to also be transparent.
        # I tried using rgba():
        #   background: "rgba(256, 256, 256, 0.4)"
        # But IE8 does not support rgba(), so I had to use a workaround for
        # IE8:
        #   background: "transparent"
        #   filter: "progid:DXImageTransform.Microsoft.gradient(startColorstr=#66FFFFFF,endColorstr=#66FFFFFF)"
        # The workaround should actually use -ms-filter because filter should
        # be for <IE8, but -ms-filter didn't work and filter did.
        # Everything worked fine, execpt for in IE8, when the transparency is
        # set this way, the mouse clicks through the element and onto the
        # elements below the shim. The click event also never fires from the
        # shim. This makes the shim useless besides looking pretty.
        # The final workaround for all this was to settle for having the
        # transparent layer separate from the button, which is what is used
        # below.
        # Note that the transparent layer is positioned normally while the
        # button is positioned absolutely. This had to be because if we
        # positioned the transparent layer instead, it would cover the button
        # and make the button transparent as well.
        self = this

        # Create the shim.
        $shim = $(@api.createElement("div")).
          addClass("snapeditor_image_shim").
          addClass("snapeditor_ignore_deactivate").
          css(
            position: "absolute"
            zIndex: SnapEditor.zIndexBase
          ).
          hide().
          appendTo(@api.doc.body)
        $innerShim = $(@api.createElement("div")).
          css(
            width: "100%"
            height: "100%"
            background: "white"
            opacity: 0.4
            filter: "alpha(opacity=40)"
          ).
          appendTo($shim)

        # Add the buttons.
        $buttons = $(@api.createElement("div")).
          addClass("snapeditor_image_shim_buttons").
          css(
            position: "absolute"
            top: 0
            left: 0
          ).
          appendTo($shim)
        $edit = $(@api.createElement("button")).
          html(SnapEditor.lang.imageEdit).
          click(->
            self.api.openDialog("image", { api: self.api }, { imageEl: self.imageEl, mutliple: false })
          ).
          appendTo($buttons)
        $delete = $(@api.createElement("button")).
          html(SnapEditor.lang.delete).
          click(->
            self.hideShim()
            $(self.imageEl).remove()
            self.api.clean(self.api.el.childNodes[0], self.api.el.childNodes[self.api.el.childNodes.length - 1])
          ).
          appendTo($buttons)

      # Set the shim styles.
      $shim.css(styles) if styles

      # Position the buttons.
      # Note that we use #measure() for buttons but not the shim because the
      # buttons are not shown yet so we get 0 for both the width and height.
      # Using #measure() ensures we get the correct size for buttons. This is
      # not needed for the shim even though it is not shown because we
      # manually assigned the width and height to the shim earlier.
      $buttons = $shim.find(".snapeditor_image_shim_buttons")
      shimSize = $shim.getSize()
      buttonsSize = $buttons.measure(-> @getSize())
      $buttons.css(
        top: parseInt((shimSize.y - buttonsSize.y) / 2, 10)
        left: parseInt((shimSize.x - buttonsSize.x) / 2, 10)
      )

      $shim

    showShim: (@imageEl) ->
      $img = $(@imageEl)
      coords = $img.getCoordinates()
      @getShim(
        top: coords.top
        left: coords.left
        width: coords.width
        height: coords.height
      ).show()

    hideShim: ->
      @getShim().hide()

  SnapEditor.behaviours.image =
    activate: (e) ->
      image.api = e.api
      image.prepareConfig()
      image.enableAutoUploader()
    deactivate: (e) ->
      image.hideShim()
      image.disableAutoUploader()
    mouseover: (e) ->
      if $(e.target).tagName() == "img"
        image.showShim(e.target)
      else
        image.hideShim()

  styles = """
    .snapeditor_image {
      width: 325px;
    }

    .snapeditor_image_tabs {
      list-style: none;
      border-bottom: 1px solid #dddddd;
      padding: 0;
      margin: 0 0 5px 0;
    }
    .snapeditor_image_tabs:before, .snapeditor_image_tabs:after {
      display: table;
      line-height: 0;
      content: "";
    }
    .snapeditor_image_tabs:after {
      clear: both;
    }
    .snapeditor_image_tab {
      float: left;
      list-style: none;
      line-height: 20px;
      margin-bottom: -1px;
    }
    .snapeditor_image_tab a {
      display: block;
      color: #0088cc;
      text-decoration: none;
      border: 1px solid transparent;
      border-radius: 4px 4px 0 0;
      padding: 8px 12px;
      line-height: 20px;
      margin-right: 2px;
    }
    .snapeditor_image_tab a:hover, .snapeditor_image_tab a:active {
      outline: 0;
    }
    .snapeditor_image_tab a:hover, .snapeditor_image_tab a:focus {
      color: #005580;
      background-color: #eeeeee;
      border-color: #eeeeee #eeeeee #dddddd;
    }
    .snapeditor_image_tabs .selected a {
      color: #555555;
      cursor: default;
      background-color: #ffffff;
      border: 1px solid #dddddd;
      border-bottom-color: transparent;
    }

    .snapeditor_image_url input[type=text] {
      width: 300px;
      margin-bottom: 10px;
    }

    .snapeditor_image_upload input[type=file] {
      margin-bottom: 20px;
    }
    .snapeditor_progress {
      width: 200px;
      height: 20px;
      overflow: hidden;
      background-color: #f7f7f7;
      background-image: linear-gradient(to bottom, #f5f5f5, #f9f9f9);
      background-repeat: x;
      -webkit-border-radius: 4px;
      border-radius: 4px;
      -webkit-box-shadow: inset 0 1px 2px rgba(0, 0, 0, 0.1);
      box-shadow: inset 0 1px 2px rgba(0, 0, 0, 0.1);
    }
    .snapeditor_progress .bar {
      float: left;
      height: 100%;
      font-size: 12px;
      color: #ffffff;
      text-align: center;
      text-shadow: 0 -1px 0 rgba(0, 0, 0, 0.25);
      background-color: #0e90d2;
      background-image: linear-gradient(to bottom, #149bdf, #0480be);
      background-repeat: repeat-x;
      -webkit-box-shadow: inset 0 -1px 0 rgba(0, 0, 0, 0.15);
      box-shadow: inset 0 -1px 0 rgba(0, 0, 0, 0.15);
      box-sizing: border-box;
      -webkit-transition: width 0.6s ease;
      transition: width: 0.6s ease;
    }
  """ + Helpers.createStyles("image", 23 * -26)
  SnapEditor.insertStyles("image", styles)
