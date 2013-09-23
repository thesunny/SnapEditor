# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
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

    css: ->
      """
        .snapeditor_dialog {
          position: absolute;
          z-index: #{SnapEditor.zIndexBase + 110};
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
      if title
        @$titleContainer.show()
        @$title.text(title)
      else
        @$titleContainer.hide()

    setHTML: (html) ->
      @$content.html(html or "")

    on: (selector, event, fn) ->
      # TODO: Currently, it doesn't seem like we need to namespace. Remove if
      # we decided not to use it.
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
        if typeof @dialog.html == "function"
          dialogHTML = @dialog.html()
        else
          dialogHTML = @dialog.html or ""
        @setHTML(dialogHTML)
        if typeof @dialog.css == "function"
          dialogCSS = @dialog.css()
        else
          dialogCSS = @dialog.css or ""
        @api.insertStyles("dialog_#{@type}", @css() + dialogCSS)
        @dialog.onSetup(dialog: this) if @dialog.onSetup

    open: (e, args) =>
      @api = e.api
      unless @opened
        @api.lockRange(@api.getRange())
        @setup()
        # The dialog must be shown before calling @dialog.onOpen() in case
        # @dialog.onOpen() calls something visual like focus(). If the dialog
        # is not shown yet, focus() will not work.
        # Also, the CSS is set here even though it is not the final CSS
        # because @dialog.onOpen() may change the content. However, the CSS
        # must be set here so that the dialog is somewhat centered in the view
        # port. If it wasn't, if @dialog.onOpen() calls focus(), it would
        # scroll the window to wherever the dialog is currently, which could
        # be anywhere. The final setting of the CSS after all content has been
        # set is at the end.
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
        @opened = true
        if @dialog.onOpen
          args.unshift($.extend(dialog: this, e))
          @dialog.onOpen.apply(@dialog, args)
        # Set the final CSS of the dialog after all content has been set.
        @$el.css(@getStyles())

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
        # @api.win.focus() must be used in Firefox when using an iframe
        # because @api.el.focus() makes the iframe jump.
        # @api.el.focus() must be used in Firefox when not using an iframe
        # because @api.win.focus() does nothing.
        # This affects IE as it makes the page jump to where the cursor is.
        # TODO: The call to @api.editor.iframe is really ugly. Figure out how
        # to fix this properly.
        @api.win.focus() if Browser.isWebkit or Browser.isGecko and @api.editor.iframe
        @api.el.focus() if Browser.isGecko and !@api.editor.iframe
        @opened = false
        # Collapse before reselecting the range because in Firefox, sometimes
        # it selects all the way to the bottom.
        @api.collapse(true)
        @api.select()
        @dialog.onClose(api: @api, dialog: this) if @dialog.onClose
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
