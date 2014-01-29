# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["snapeditor.pre", "jquery.custom", "plugins/helpers"], (SnapEditor, $, Helpers) ->
  insertCodeBlock = (e) ->
    # TODO:
    # CHROME ENTER bug
    # There is a really weird bug in chrome. After you insert a code block
    # you have to hit enter twice for the actual enter works. Doesn't seem
    # to be a problem for the tags that already existing.
    #
    # * Tried with and without inner text but no change
    # * Tried explicitly inserting a text node but no change
    #
    # Narrowed it down to only when your cursor is at the end of the <pre>
    # element.
    #
    # FIREFOX ENTER BUG
    #
    # There is a similar (but not same) bug in chrome. When you hit enter,
    # you don't see the enter until you type another character. It's like
    # the newline character is there, but the visible break does not appear
    # until you type another character.
    api = e.api

    # Handle the special case when inserting at the end of the editable
    # area.
    isEndOfEditableArea = api.isEndOfElement(api.el)

    # We add in the zeroWidthNoBreakSpace because otherwise Chrome shows a
    # squished version of the <pre> element. The zero width space gives the
    # <pre> some height.
    el = api.insert("<pre id=\"INSERTED_CODE_BLOCK\">#{Helpers.zeroWidthNoBreakSpace}</pre><p></p>")
    elToSelect = api.doc.getElementById("INSERTED_CODE_BLOCK")
    api.selectEndOfElement(elToSelect)
    if isEndOfEditableArea
      $block = $(api.getDefaultBlock()).html(Helpers.zeroWidthNoBreakSpace)
      $block.insertAfter(elToSelect)    
    api.clean()

  SnapEditor.defActions
    pre: insertCodeBlock

  SnapEditor.defButtons
    pre: Helpers.createButton("pre")