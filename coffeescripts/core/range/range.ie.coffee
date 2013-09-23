# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
# This returns an object that contains static and instance functions. The
# expected usage is to extend a class with the static functions and to include 
# the instance functions.
#
# Range Intro from QuirksMode:
# http://www.quirksmode.org/dom/range_intro.html
#
# IE TextRange Prototype:
# http://msdn.microsoft.com/en-us/library/dd347140(v=vs.85).aspx
# IE ControlRange Prototype:
# http://msdn.microsoft.com/en-us/library/ms537447(v=vs.85).aspx
#
# NOTE: IE9+ supports W3C ranges. Therefore, it does not use this code. Please
# take a look at range.w3c.coffee for IE9+.
define ["core/helpers"], (Helpers) ->
  return {
    static:
      # Get a brand new range.
      getBlankRange: (win = window) ->
        win.document.body.createTextRange()

      # Gets the currently selected range.
      getRangeFromSelection: (win = window) ->
        try
          # In IE, there is no way to tell if a selection is available. We
          # have to let the code fail and catch it.
          # In IE7, win.document.selection.createRange() throws an error, but
          # the error cannot be caught.
          # In IE8, win.document.selection.createRange() gives a blank range.
          # However, in both IE7/8, when there is no selection, the typeDetail
          # property throws an error that is catchable. We use that instead.
          win.document.selection.typeDetail
          # In an iframe, typeDetail does not throw an error. Instead it flows
          # through to createRange(). It actually creates a range, but it's
          # not valid. It is actually a range in the parent page, not the
          # iframe. It's parent element is the body of the parent page, not
          # the iframe. Therefore, we check the parent element to see if it's
          # window is the same as the given win. If it's not, then we have an
          # invalid range and return null.
          range = win.document.selection.createRange()
          if Helpers.getWindow(@getParentElement(range)) == win
            return range
          else
            return null
        catch error
          return null

      # Get a range that surrounds the content of el.
      getRangeFromElement: (el) ->
        doc = Helpers.getDocument(el)
        if el.nodeName == 'IMG'
          range = doc.body.createControlRange()
          range.add(el)
        else
          range = doc.body.createTextRange()
          range.moveToElementText(el)
        range

      getParentElement: (range) ->
        if range.parentElement
          # TextRange
          range.parentElement()
        else
          # ControlRange
          range.item(0)

    instance:
      #
      # HELPER FUNCTIONS
      #
      cloneRange: ->
        if @isImageSelected()
          @constructor.getRangeFromElement(@range.item(0))
        else
          @range.duplicate()

      #
      # QUERY RANGE STATE FUNCTIONS
      #

      # Is the selection a caret.
      isCollapsed: ->
        !@isImageSelected() && @range.text.length == 0

      # Is an image selected.
      isImageSelected: ->
        # ControlRanges do not have a parentELement attribute.
        @range and typeof @range.parentElement == "undefined"

      # Returns true if the current range is at the start of the given element.
      # We are at start of element if there are no width-generating characters.
      # This includes all characters except for newline, space and tab
      # However, &nbsp; does create a space which is why we can't use \S.
      #
      # NOTE: If you print out startText, you will not see &nbsp;. It looks
      # like a normal space.
      #
      # NOTE: IE9 changes &nbsp; to space whenever using #innerText. This is
      # why we can't use the easier function of range.toString() because it
      # uses #innerText to grab the text.The other W3C browsers keep &nbsp; as
      # character code 160. As a workaround, we grab all the textnodes and get
      # the text using nodeValue and concatenate them togther. Fortunately,
      # jQuery does this already with the #text() function.
      isStartOfElement: (el) ->
        elRange = @constructor.getRangeFromElement(el)
        range = @cloneRange()
        range.setEndPoint("StartToStart", elRange)
        startText = range.htmlText
        startText.match(Helpers.emptyRegExp)

      # Returns true if the current range is at the end of the given element.
      # We are at end of the element if there are no width-generating
      # characters. This includes all characters except for newline, space and
      # tab. However, &nbsp; does create a space which is why we can't use \S.
      #
      # NOTE: If you print out endText, you will not see &nbsp;. It looks like
      # a normal space.
      #
      # NOTE: IE9 changes &nbsp; to space whenever using #innerText. This is
      # why we can't use the easier function of range.toString() because it
      # uses #innerText to grab the text.The other W3C browsers keep &nbsp; as
      # character code 160. As a workaround, we grab all the textnodes and get
      # the text using nodeValue and concatenate them togther. Fortunately,
      # jQuery does this already with the #text() function.
      isEndOfElement: (el) ->
        elRange = @constructor.getRangeFromElement(el)
        range = @cloneRange()
        range.setEndPoint("EndToEnd", elRange)
        endText = range.htmlText
        endText.match(Helpers.emptyRegExp)

      # Get immediate parent element.
      getImmediateParentElement: ->
        # Only textranges have parentElement. Controlranges do not.
        (@isImageSelected() and @range.item(0)) or @range.parentElement()

      # Get the text in the range.
      getText: ->
        # IE adds '\n' and '\r' between elements. We clean this up.
        (@range.text or "").replace(/[\n\r]/g, "")

      # TODO: Confirm that this is no longer used. Remove the test if so.
      # Returns an object representing the area between the current range
      # and the start of a parent element.
      #getStart: (match) ->
        #parent = @getParentElement(match)
        #if parent
          #range = @getRangeFromElement(parent)
          ## console.log(range, @range)
          ## range.setEndPoint('EndToStart', @range)
          #text = range.text #.replace(/\s/g, ' ')
          #start =
            #range: (new Editor.Range(@el, range)),
            #text: text
        #start

      #
      # MANIPULATE RANGE FUNCTIONS
      #

      collapse: (start) ->
        # When an image is selected, the range does not have a collapse()
        # function to call.
        @range.collapse(start) unless @isImageSelected()
        this

      # Select the given range or its own range if none given.
      select: (range) ->
        range or= @range
        range.select()
        @range = range
        this

      # Unselect the range.
      unselect: () ->
        @doc.selection.empty()

      # Select the contents of the element.
      # NOTE: IE8 cannot select the contents when the element is a block. It
      # selects the entire block. IE7 is fine.
      selectElementContents: (el) ->
        @range.moveToElementText(el)
        @select()

      # Move selection to the inside of the end of the element.
      #
      # NOTE: There used to be the following problem.
      # When selecting the element and collapsing to the end, the range falls
      # outside of the element.
      #   select: <div>|text</div>|
      #   collapse: <div>text</div>|
      # The range does not end up at the end of the inside of the element.
      # However, if it is a table cell, it does fall at the end of the inside
      # of the cell.
      #   select: <tr><td>|text|</td><td>more</td></tr>
      #   collapse: <tr><td>text|</td><td>more</td></tr>
      # FIX: We noticed that collapsing to the start always left it inside the
      # element. Unfortunately, we could not just move the start to where the
      # end was as that would have the same effect as collapsing to the end.
      # Instead, we count the number of characters and move the start using the
      # count. This guarantees that the the start will remain inside the
      # element and at the end.
      selectEndOfElement: (el) ->
        @moveToEndOfElement(el)
        @select()

      # Move range to the inside of the end of the element.
      #
      # NOTE: There used to be the following problem.
      # When selecting the element and collapsing to the end, the range falls
      # outside of the element.
      #   select: <div>|text</div>|
      #   collapse: <div>text</div>|
      # The range does not end up at the end of the inside of the element.
      # However, if it is a table cell, it does fall at the end of the inside
      # of the cell.
      #   select: <tr><td>|text|</td><td>more</td></tr>
      #   collapse: <tr><td>text|</td><td>more</td></tr>
      # FIX: We noticed that collapsing to the start always left it inside the
      # element. Unfortunately, we could not just move the start to where the
      # end was as that would have the same effect as collapsing to the end.
      # Instead, we count the number of characters and move the start using the
      # count. This guarantees that the the start will remain inside the
      # element and at the end.
      moveToEndOfElement: (el) ->
        @range.moveToElementText(el)
        # When getting text, <br> is replaced with /r/n (2 characters).
        # However, when moving by character the <br> is counted as a single
        # character. To get around this problem, we strip any \r before
        # counting.
        @range.moveStart("character", @range.text.replace(/\r/g, "").length)
        @range.collapse(true)

      # Saves the range, executes the given fn, then reselects the range.
      # The function is given the start and end spans as arguments.
      #
      # NOTE: This inserts spans at the beginning and end of the range. These
      # cannot be removed. If they are, the reselection will fail. Be careful
      # what the given function does.
      keepRange: (fn) ->
        isImage = @isImageSelected()
        if isImage
          image = @range.item(0)
          $(image).attr("id", "RANGE_IMAGE")
          startElement = image
          endElement = image
        else
          # Place spans at the start and end of the range.
          range = @constructor.getBlankRange(@win)
          range.setEndPoint("StartToStart", @range)
          range.collapse(true)
          range.pasteHTML('<span id="RANGE_START"></span>')
          range.setEndPoint("StartToEnd", @range)
          range.collapse(false)
          range.pasteHTML('<span id="RANGE_END"></span>')
          startElement = @find("#RANGE_START")[0]
          endElement = @find("#RANGE_END")[0]
        fn(startElement, endElement)
        # Refind the start and end in case the function had modified them.
        if isImage
          @range = @constructor.getRangeFromElement(@find("#RANGE_IMAGE")[0])
        else
          $start = @find("#RANGE_START")
          $end = @find("#RANGE_END")
          range.moveToElementText($start[0])
          @range.setEndPoint("StartToStart", range)
          range.moveToElementText($end[0])
          @range.setEndPoint("EndToStart", range)
          $start.remove()
          $end.remove()
        @select()

      boundariesMap:
        starttostart: "StartToStart"
        starttoend: "StartToEnd"
        endtostart: "EndToStart"
        endtoend: "EndToEnd"

      # Moves one of the range's boundary to the start/end of the el.
      # Arguments:
      # * boundaries - "StartToStart", "StartToEnd", "EndToStart", "EndToEnd"
      # * el - element to move to
      #
      # The first boundary refers to the range's boundary. The second boundary
      # refers to the el's boundary. Capitalization is normalized.
      moveBoundary: (boundaries, node) ->
        origBoundaries = boundaries
        boundaries = boundaries.toLowerCase()
        ieBoundaries = @boundariesMap[boundaries]
        throw "The given boundaries (#{origBoundaries}) must be one of [StartToStart, StartToEnd, EndToStart, EndToEnd]" unless ieBoundaries
        el = node
        isTextnode = Helpers.isTextnode(node)
        # If the node is a textnode, we add a <span> to the start/end and use
        # that to create our range.
        if isTextnode
          parent = node.parentNode
          el = @createElement("span")[0]
          # Add the zero width no break space so we have some text to select.
          el.innerHTML = Helpers.zeroWidthNoBreakSpace
          switch ieBoundaries
            when "StartToStart", "EndToStart"
              parent.insertBefore(el, node)
            when "StartToEnd", "EndToEnd"
              parent.insertBefore(el, node.nextSibling)
        elRange = new @constructor(@el)
        switch ieBoundaries
          when "StartToStart", "EndToStart"
            if isTextnode
              # Unfortunately, when we set EndToStart and remove the <span>
              # afterwards, the range jumps to the previous text. This causes
              # problems when the text is inside another element.
              # Example:
              #   Scenario.
              #     before<span>|middle|</span>after
              #     range = <span>
              #     node = after
              #   After adding our <span> marker and moving the boundary.
              #     before<span>|middle</span><span>|&#65279;</span>after
              #   After removing our span marker.
              #     before<span>|middle|</span>after
              #   This is clearly wrong. The end should be after the <span>.
              #
              #   To fix this, we note that the marker <span> will be removed
              #   anyways. Hence, selecting the beginning of the marker or the
              #   end doesn't matter, except that selecting the end keeps the
              #   range in the proper place after removal.
              #   After adding our <span> marker and moving the boundary.
              #     before<span>|middle</span><span>&#65279;|</span>after
              #   After removing our span marker.
              #     before<span>|middle</span>|after
              #   This is now correct.
              elRange.range = @constructor.getBlankRange(@win)
              elRange.selectEndOfElement(el)
            else
              elRange.range = @constructor.getRangeFromElement(el)
          when "StartToEnd", "EndToEnd"
            elRange.range = @constructor.getBlankRange(@win)
            elRange.moveToEndOfElement(el)
        @range.setEndPoint(ieBoundaries, elRange.range)
        if isTextnode
          parent = node.parentNode
          parent.removeChild(el)

      #
      # MODIFY RANGE CONTENT FUNCTIONS
      #

      # Insert the given node and set the selection to after the node.
      #   text|
      #   <div>element</div>|
      #
      # NOTE: In W3C, we manually need to move the caret. In IE, the insertHTML
      # method automatically moves the caret to after the end of the inserted
      # node.
      #
      # NOTE: In IE, the inserted node is a copy of the node given.  In W3C,
      # the actual node is inserted in. Although I can normalize this, in some
      # special cases, we may need access to that node for W3C only so I have
      # not removed reference-ability in W3C. 
      insertNode: (node) ->
        div = @doc.createElement("div")
        div.appendChild(node)
        @insertHTML(div.innerHTML)

      # Insert HTML and set the selection to after the HTML.
      #   text|
      #   <div>element</div>|
      #
      # NOTE: In W3C, we manually need to move the caret. In IE, the insertHTML
      # method automatically moves the caret to after the end of the inserted
      # node.
      #
      # NOTE: IE attempts to be too smart when placing the selection after
      # pasting elements. It does not always go after the elements. Furthermore,
      # IE7 behave differently in certain situations.
      # Inline element (not <a>):
      #   If the inserted element has content and there's no content
      #   afterwards, the selection always goes at the end of the inside of
      #   the element.
      #     <span>test|</span>
      #   If the inserted element has content and there's content afterwards,
      #   it depends on the IE version.
      #     IE7: <span>test|<span>after
      #     IE8: <span>test</span>|after
      #   If the inserted element has no content, it depends on what's around.
      #     <span>|<span>
      #     <span></span>|after
      #     before|<span></span>
      # <a>:
      #   If <a> has content, the selection always goes after <a>.
      #     <a>test</a>|
      #     <a>test</a>|after
      #   If <a> has no content and there is no content around, it depends on
      #   the IE version.
      #     IE7: <a>|</a>
      #     IE8: |<a></a>
      #   If <a> has no content and there is content around, it depends on
      #   what's around.
      #     <a></a>|after
      #     before|<a></a>
      # Block element (including inline element as block) and no content
      # afterwards.
      #   <div>|</div>
      #   <div>test|</div>
      #   before<div>|</div>
      #   before<div>test|</div>
      # Block element (including inline element as block) with content and
      # content afterwards.
      #   <div>test</div>|after
      insertHTML: (html) ->
        # In IE7, in order for the selection to be placed after the inserted
        # node automatically, the range must be selected first. There is no
        # harm in leaving this in for other versions.
        @select()
        # If an image is selected, we have a controlRange. Remove the image and
        # refind the range.
        if @isImageSelected()
          $(@range.item(0)).remove()
          @range = @constructor.getRangeFromSelection(@win)
        @range.pasteHTML(html)

      # Surround range with element and place the selection after the element.
      surroundContents: (el) ->
        if @isImageSelected()
          el.innerHTML = @range.item(0).outerHTML
        else
          el.innerHTML = @range.htmlText
        @insertNode(el)

      # Delete the contents of the range.
      delete: ->
        @select()
        [startElement, endElement] = @getParentElements((el) -> Helpers.isBlock(el))
        deleted = $(startElement).closest("td, th", @el)[0] == $(endElement).closest("td, th", @el)[0]
        if deleted
          @range.execCommand("delete")
          # IE7/8 loses the range after deletion. We have to manually grab it
          # again from the selection.
          @range = @constructor.getRangeFromSelection(@win)
        return deleted
  }
