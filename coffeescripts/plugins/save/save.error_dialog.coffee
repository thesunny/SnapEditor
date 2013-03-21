define ["jquery.custom", "ui/ui.dialog"], ($, Dialog) ->
  class ErrorDialog extends Dialog
    getHTML: ->
      """
        <div class="error"></div>
        <button class="okay">#{@api.config.lang.formOk}</button>
      """

    setup: ->
      unless @$el
        super(title: @api.config.lang.saveErrorTitle, html: @getHTML())
        @$error = @$el.find(".error")
        @$okay = @$el.find(".okay").on("click", @hide)

    show: (api, message) =>
      super(api)
      @$error.text(message)
