define ["jquery.custom", "core/helpers", "ui/ui.dialog"], ($, Helpers, Dialog) ->
  # Triggers:
  # * save
  # * resume
  # * discard
  class PromptDialog extends Dialog
    getHTML: ->
      """
        <div class="save_dialog">
          <div class="message">#{@api.config.lang.saveExitMessage}</div>
          <div class="buttons">
            <button class="save submit button">#{@api.config.lang.saveSaveButton}</button>
            <button class="cancel button">#{@api.config.lang.formCancel}</button>
          </div>
          <div class="discard_message">
            #{@api.config.lang.saveOr} <a class="discard" href="javascript:void(null);">#{@api.config.lang.saveDiscardChanges}</a>
          </div>
        </div>
      """

    setup: ->
      unless @$el
        super(title: @api.config.lang.saveTitle, html: @getHTML())
        @$save = @$el.find(".save").on("click", => @trigger("save"))
        @$cancel = @$el.find(".cancel").on("click", => @trigger("resume"))
        @$discard = @$el.find(".discard").on("click", => @trigger("discard"))
