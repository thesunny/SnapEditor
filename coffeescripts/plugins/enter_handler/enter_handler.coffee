# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["snapeditor.pre", "jquery.custom", "core/helpers", "core/browser"], (SnapEditor, $, Helpers, Browser) ->
  enterHandler =
    activate: (@api) ->
      self = this
      @onkeydownHandler = (e) -> self.onkeydown(e)
      @api.on("snapeditor.keydown", @onkeydownHandler)

    deactivate: ->
      @api.off("snapeditor.keydown", @onkeydownHandler)

    onkeydown: (e) ->
      if Helpers.keysOf(e) == "enter"
        e.preventDefault()
        @handleEnterKey(@api)
      # else
      #   @dumpElement @getParentElement(), "OTHER KEY"

    # onkeydownCaptureIE: (e) ->
    #   if Helpers.keysOf(e) == "enter"
    #     console.log "PREVENT DEFAULT DURING CAPTURE"
    #     e.preventDefault()

    handleEnterKey: (@api) ->
      if @api.delete()
        parent = @getParentElement()
        # TODO: This hard coded check should be one of the returns of @api.getNext.
        # Perhaps something like it return "\n" or something.
        if parent.tagName.toLowerCase() == "pre"
          next = "newline"
        else if parent
          next = @api.getNext(parent)
        else
          next = @api.getDefaultBlock()

        if next == "newline"
          @handleNewline()
        else if $(next).tagName() == "br"
          @handleBR(next)
        else
          @handleBlock(parent, next)
        @api.clean()

    # TODO:
    # Consider renaming this method. It doesn't just get the parent element,
    # it will also clean the DOM if a parent element doesn't exist.
    # Maybe something like getParentElementWithClean
    getParentElement: ->
      parent = @api.getParentElement()
      # If no parent is found, the text is at the top level. This is not
      # correct and so we have to perform a clean. After the clean, the parent
      # should exist.
      # This can occur right after a table that is at the end of the editable
      # area. The cursor can be placed after the table but before the end of
      # the editable area by using the down/right arrow keys or by simply
      # clicking the area to the right of the table. Text that is entered is at
      # the top level.
      unless parent
        @api.clean()
        parent = @api.getParentElement()
      parent

    # TODO:
    # Unit test this baby cross platform!
    handleNewline: ->
      parentElement = @getParentElement()
      doc = Helpers.getDocument(parentElement)
      # Chrome Bug
      #
      # You have to hit enter twice for newline to work in Chrome.
      # It doesn't matter when you hit enter the first time,
      # even if you type, hit enter, type then hit enter, the second
      # enter will work. If you open up the DOM inspector and watch it
      # while hitting enter, it will actually work.
      #
      # Adding the zeroWidthNoBreakSpaceUnicode fixes the problem.
      #
      #   "\n" + Helpers.zeroWidthNoBreakSpaceUnicode
      #
      # Feels a bit hacky though.
      #
      # This now was fixed the same way the Internet Explorer Bug was fixed.
      #
      #
      # W3C Internet Explorer Bug
      #
      #     abc|
      #
      # Hit enter to get:
      #
      #     abc
      #     |
      #
      # Type:
      #
      #     abc|
      #     def
      #
      # Hit enter and get:
      #
      #     abcdef
      #     |
      #
      # As you hit enter and insert newlines, various text in the <pre> tag
      # disappear. Some workarounds I tried:
      #
      # * Looked to use insertHTML but this method is not available on the W3C
      #   version of the range.
      # * Tried to not handle the enter and let IE handle it itself but this
      #   results in a new <pre> element created instead of a newline inside of
      #   the pre element.
      # * It works if you use @handleBR instead but then you end up with
      #   <br> tags inside your <pre> which feels undesirables. May be a last
      #   ditch effort though for a markup editor since the <br> will
      #   ultimately be removed anyways. One problem right now is that the
      #   **cleaner** will remove the <br> tag which it should do.
      # * PROMISING: If you put a character like the letter "a" before the
      #   newline, this works; however, if you put a "|" or zero width space in
      #   front of the newline it doesn't work.
      # * Extra Nodes: Tried adding a separate node with the no width space
      #   before adding the newline node. Still doesn't work.
      # * Tried adding a span before the newline which does work but only if
      #   the cleaner is turned off. And of course, it leaves a span tag in
      #   the middle of your text.
      # * Tried removing the unnecessary (for IE) #selectAfterElement in
      #   range.w3c.coffee but it didn't make a difference.
      # * Tried it with zeroWidthNoBreakSpace before but doesn't work
      # * Tried it with crlf before but doesn't work
      # * Changed \n to \t and the behavior is the same. Something to do with
      #   space characters?
      # * Tried inserting newlineNode twice (separately) which gave different
      #   behavior than inserting 2 newlines in a single node. In this case,
      #   it only deleted one of the newlines.
      #
      # Incomplete Solution:
      #
      # Insert a newline as a node. Then insert, separately, the zero width
      # space as a node; however, the solution has a problem in that the cursor
      # can end up in front of the zeroWidth space at the beginning of a line. 
      # When you type then hit enter, we get the old problem back.
      #
      # This seems to confirm that IE is cleaning up previous contenteditable
      # generated newlines back to the last non-contenteditable generated
      # newline.
      #
      # Things to investigate:
      #
      # So the insert node being "[\n" is something interesting to look at
      # and investigate. What's happening is that when we inspect the character
      # codes, the newline and the "[" have been removed even before we get
      # a chance to insert. We know this because we dumped the contents of the
      # node and looked at each charCode (see #dumpElement). At the same time,
      # the DOM includes the newlines before the keydown event. One thing to
      # try again (when my brain isn't so dead), is to see if we can
      # preventDefault() during the capture phase. It feels like IE is doing
      # some clean up on its own when enter is being pressed. I tried this
      # unsuccessfully but given that I'm getting tired, I'm not 100% sure
      # if I checked everything correctly. It's worth trying again.
      #
      # Interesting:
      # Another thing to look at is patterns for how the newline is distributed
      # across the text nodes to find out if there are specific patterns that
      # work okay and then replicate it by going through all the nodes and
      # fixing it. Maybe just joining all the text nodes together will fix
      # the problem.
      #
      # Complete Solution:
      #
      # The incomplete solution gave me some clues which included the fact that
      # it made a different that the no width space was inserted in a separate
      # node. This suggested that the composition of each text node and what
      # was in each of the text nodes made a difference. My instinct was that
      # Internet Explorer was trying to clean the nodes but not doing it
      # properly.
      #
      # So I tried just joining all the adjacent text nodes together.
      #
      # This worked!
      #
      # In fact, it also solved the Chrome bug properly at the same time.
      newlineNode = doc.createTextNode("\n")
      # console.log "newlineNode: " + newlineNode
      # Helpers.dumpElementChildren parentElement, "BEFORE INSERT"
      # @api.getRange().insertNode(newlineNode)
      if Browser.isIE8
        @api.getRange().insertNodeAlternate(newlineNode)
      else
        @api.getRange().insertNode(newlineNode)
      # @api.getRange().insertHTML(newlineText)
      # Helpers.dumpElementChildren parentElement, "AFTER INSERT"
      # console.log "After inserting node as TextNode"
      # parentElement = @getParentElement()
      # if Browser.isIE
      #   spaceNode = doc.createTextNode(Helpers.zeroWidthNoBreakSpaceUnicode)
      #   @api.getRange().insertNode(spaceNode)
      if Browser.isIE10 or Browser.isIE11 or Browser.isWebkit
        @api.keepRange =>
          @mergeAdjacentTextnodes parentElement

    mergeAdjacentTextnodes: (parentElement) ->
      lastAdjacentTextnode = null
      Helpers.eachChild parentElement, (node) =>
        if Helpers.isTextnode node
          if lastAdjacentTextnode
            lastAdjacentTextnode.nodeValue = lastAdjacentTextnode.nodeValue + node.nodeValue
            $(node).remove()
          else
            lastAdjacentTextnode = node
        else
          lastAdjacentTextnode = null

    handleBR: (next) ->
      # When there is no text after the <br>, the caret cannot be placed
      # afterwards. With the zero width break space, the caret can now be
      # placed after the <br>.
      @api.insert("#{next.outerHTML}#{Helpers.zeroWidthNoBreakSpace}")

    handleBlock: (block, next) ->
      if block
        # If a block is given, the parent is the block.
        isEndOfElement = @api.isEndOfElement(block)
        if $(block).tagName() == "li" and isEndOfElement and @api.isStartOfElement(block)
          # Empty list item, so outdent.
          @api.outdent()
        else if isEndOfElement
          # Hitting enter at the end of an element. Add the next block and
          # place the selection in it.
          $(next).insertAfter(block).html(Helpers.zeroWidthNoBreakSpace)
          @api.selectEndOfElement(next)
        else
          # In the middle of a block. Split the block and place the selection in
          # the second block.
          @api.keepRange((startEl, endEl) ->
            $span = $('<span id="ENTER_HANDLER"/>').insertBefore(startEl)
            [$first, $second] = $(block).split($span)
            # Insert a <br/> if $first is empty.
            if $first[0].childNodes.length == 0 or ($first[0].childNodes.length == 1 and $first[0].firstChild.nodeType == 3 and $first[0].firstChild.nodeValue.match(/^[\n\t ]*$/))
              $first.html("&nbsp;")
            $span.remove()
          )
      else
        # If no block is given, that means we are at the top of the editable
        # element.
        $next = $(next).attr("id", "ENTER_HANDLER").html(Helpers.zeroWidthNoBreakSpace)
        @api.insert($next[0])
        $next = $(@api.find("#ENTER_HANDLER")).removeAttr("id")
        @api.selectEndOfElement($next[0])

  SnapEditor.behaviours.enterHandler =
    onActivate: (e) -> enterHandler.activate(e.api)
    onDeactivate: (e) -> enterHandler.deactivate()

  # enterHandler is returned for tesing purposes.
  return enterHandler
