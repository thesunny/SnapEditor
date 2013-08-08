define ["jquery.custom", "plugins/helpers"], ($, Helpers) ->
  # api.config.imageServer


  SnapEditor.widgets.image =
    onCreate: (e) ->

    onEdit: (e) ->

  SnapEditor.dialogs.image =
    title: SnapEditor.lang.imageUploadTitle

    html: ""

    onSetup: (e) ->

    onOpen: (e) ->
      @api = e.api

    onClose: (e) ->

    insertImage: (url, width, height) ->
      $img = $(@api.createElement("img"))
      $img.attr(id: "SNAPEDITOR_INSERTED_IMAGE", src: url, width: width, height: height)
      @api.insert($img[0])
      $(@api.find("#SNAPEDITOR_INSERTED_IMAGE")).removeAttr("id")

  SnapEditor.actions.image = (e) -> e.api.showDialog("image", e)

  SnapEditor.buttons.image = Helpers.createButton("image", "ctrl+g", onInclude: (e) ->
    e.api.config.behaviours.push("image")
    e.api.addWhitelistRule("Image", "img[src, width, height]")
  )

  selectImage = (e) ->
    $el = $(e.target)
    # Webkit fails to actually select the image when clicking on it. Hence,
    # we manually select it. This does not break other browsers so it is left
    # in for consistency.
    e.api.select($el[0]) if $el.tagName() == "img"
  SnapEditor.behaviours.image =
    onActivate: (e) -> $(e.api.el).on("mousedown", selectImage)
    onDeactivate: (e) -> $(e.api.el).off("mousedown", selectImage)

  styles = """
    .snapeditor_dialog .insert_image_form .insert_image_text {
      margin-bottom: 10px;
    }
  """ + Helpers.createStyles("image", 23 * -26)
  SnapEditor.insertStyles("image", styles)
