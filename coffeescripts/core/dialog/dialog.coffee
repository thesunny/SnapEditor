define ["jquery.custom", "core/helpers", "core/browser"], ($, Helpers, Browser) ->
  class Dialog
    constructor: (@type) ->
      @dialog = SnapEditor.dialogs[@type]
      throw "Dialog does not exist - #{@type}" unless @dialog

    template: """
      <div class="snapeditor_dialog snapeditor_ignore_deactivate">
        <div class="snapeditor_dialog_title_container">
          <div class="snapeditor_dialog_title"></div>
        </div>
        <div class="snapeditor_dialog_content"></div>
      </div>
    """

    css: """
      .snapeditor_dialog {
        position: absolute;
        z-index: 210;
        border: 1px solid #b8b8b8;
        background-color: #FBFBFB;
        font-color: #333333;
        font-size: 14px;
        font-family: Arial, Helvetica, sans-serif;
      }

      .snapeditor_dialog_title_container {
        background: #F0F0F0;
        filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#F5F5F5', endColorstr='#E6E6E6');
        background: -webkit-gradient(linear, left top, left bottom, from(#F5F5F5), to(#E6E6E6));
        background: -moz-linear-gradient(top, #F5F5F5, #E6E6E6);
        border-bottom: 1px solid #b8b8b8;
      }

      .snapeditor_dialog_title {
        font-weight: bold;
        padding: 3px 5px;
      }

      .snapeditor_dialog_content {
        padding: 20px;
      }

      .snapeditor_dialog .error {
        color: #b94a48;
        background-color: #f2dede;
        border: 1px solid #eed3d7;
        padding: 8px 15px;
        margin-bottom: 20px;
      }

      .snapeditor_dialog .button {
        border: none;
        border: 1px solid rgba(0, 0, 0, 0.1);
        border-radius: 5px 5px 5px 5px;
        cursor: pointer;
        outline: none;
        padding: 0.50em 1em;
        text-decoration: none;
      }

      .snapeditor_dialog .submit {
        background: #83c312;
        background: -webkit-gradient(linear, left top, left bottom, from(#9bc03a), to(#649d00));
        background: -moz-linear-gradient(top , #9bc03a, #649d00);
        filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#9bc03a', endColorstr='#649d00');
        color: #ffffff;
      }

      .snapeditor_dialog .delete {
        background: #cd1313;
        background: -webkit-gradient(linear, left top, left bottom, from(#d73e3e), to(#ba0000));
        background: -moz-linear-gradient(top , #d73e3e, #ba0000);
        filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#d73e3e', endColorstr='#ba0000');
        color: #ffffff;
      }

      .snapeditor_dialog .cancel {
        background: #dddddd;
        background: -webkit-gradient(linear, left top, left bottom, from(#ededed), to(#cdcdcd));
        background: -moz-linear-gradient(top , #ededed, #cdcdcd);
        filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#ededed', endColorstr='#cdcdcd');
        color: #666666;
      }
    """

    setTitle: (title) ->
      if typeof title == "undefined"
        @$titleContainer.hide()
      else
        @$titleContainer.show()
        @$title.text(title)

    setHTML: (html) ->
      @$content.html(html or "")

    on: (selector, event, fn) ->
      domEvent = event.replace(/^snapeditor\./, "")
      self = this
      @$el.find(selector).on(domEvent, (e) ->
        fn.apply(self.dialog, [
          api: self.api
          dialog: self
          domEvent: e
        ])
      )

    find: (selector) ->
      @$el.find(selector).toArray()

    setup: ->
      unless @$el
        @$el = $(@template).hide().appendTo("body")
        @$titleContainer = @$el.find(".snapeditor_dialog_title_container")
        @$title = @$el.find(".snapeditor_dialog_title")
        @setTitle(@dialog.title)
        @$content = @$el.find(".snapeditor_dialog_content").addClass("snapeditor_dialog_content_#{@type}")
        @$content.css(
          width: @dialog.width or "auto"
          height: @dialog.height or "auto"
        )
        @setHTML(@dialog.html)
        @api.insertStyles("dialog_#{@type}", @css + @dialog.css)
        if @dialog.onSetup
          @dialog.onSetup(
            dialog: this
          )

    open: (e, args) =>
      @api = e.api
      unless @opened
        @api.lockRange(@api.getRange())
        @setup()
        @$el.css(@getStyles()).show()
        # Uses mousedown because the toolbar uses mouseup to show the dialog. If
        # mouseup was used to close, the following would happen:
        # 1. Toolbar button triggers mouseup
        # 2. Show dialog
        # 3. Add mouseup listener to close
        # 4. Propagation of mouseup to document
        # 5. close dialog
        # Therefore, the dialog will never show! Using mousedown avoids this
        # problem as mousedown has already propagated before mouseup is even
        # fired.
        @api.on(
          "snapeditor.mousedown": @close
          "snapeditor.document_mousedown": @tryMouseClose
          "snapeditor.document_keyup": @tryKeyClose
        )
        # In Firefox, if we don't set the focus on the dialog first, the focus on
        # the input will not work.
        # In Webkit, if we don't set the focus on the window first, the second
        # time the dialog is shown, the focus on the input will not work.
        # We use window.focus() instead of @$dialog[0].focus() because
        # focusing on the dialog does not fix Webkit. Focusing on the window
        # fixes Firefox.
        # This affects only IE8. It does not affect >IE8.
        window.focus() unless Browser.isIE8
        @opened = true
        if @dialog.onOpen
          args.unshift($.extend(dialog: this, e))
          @dialog.onOpen.apply(@dialog, args)

    close: =>
      if @opened
        @$el.hide()
        @api.off(
          "snapeditor.document_mousedown": @tryMouseClose
          "snapeditor.document_keyup": @tryKeyClose
        )
        # In Webkit and Firefox, we have to manually move the focus back to the
        # editor.
        # @api.win.focus() must be used in Webkit because @api.el.focus() makes
        # the page jump.
        # @api.el.focus() must be used in Firefox because @api.win.focus() does
        # nothing.
        # This affects IE as it makes the page jump to where the cursor is.
        @api.win.focus() if Browser.isWebkit
        @api.el.focus() if Browser.isGecko
        @opened = false
        if @dialog.onClose
          @dialog.onClose(
            api: @api
            dialog: this
          )
        @api.unlockRange()

    tryMouseClose: (e) =>
      @close() if $(e.target).closest(@$el).length == 0

    tryKeyClose: (e) =>
      @close() if Helpers.keysOf(e) == "esc"

    getStyles: ->
      elSize = @$el.getSize()
      windowSize = $(window).getSize()
      windowScroll = $(window).getScroll()
      return {
        top: windowScroll.y + ((windowSize.y - elSize.y) / 2)
        left: windowScroll.x + ((windowSize.x - elSize.x) / 2)
      }
