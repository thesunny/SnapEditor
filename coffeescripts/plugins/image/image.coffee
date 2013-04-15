define ["jquery.custom", "plugins/helpers", "plugins/image/image.upload_dialog"], ($, Helpers, Dialog) ->
  image =
    showDialog: (api) ->
      @dialog or= new Dialog(api.config.imageServer)
      @dialog.show(api)
    selectImage: (e) ->
      $el = $(e.target)
      # Webkit fails to actually select the image when clicking on it. Hence,
      # we manually select it. This does not break other browsers so it is left
      # in for consistency.
      e.api.select($el[0]) if $el.tagName() == "img"

  SnapEditor.commands.image = Helpers.createCommand("image", "ctrl+g", (e) -> image.showDialog(e.api))

  SnapEditor.behaviours.image =
    onActivate: (e) -> $(e.api.el).on("mousedown", image.selectImage)
    onDeactivate: (e) -> $(e.api.el).off("mousedown", image.selectImage)

  styles = """
    .snapeditor_dialog .insert_image_form .insert_image_text {
      margin-bottom: 10px;
    }
  """ + Helpers.createStyles("image", 23 * -26)
  SnapEditor.insertStyles("image", styles)
