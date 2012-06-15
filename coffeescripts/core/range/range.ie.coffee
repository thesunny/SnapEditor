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
      getBlankRange: ->
        document.body.createTextRange()

      # Gets the currently selected range.
      getRangeFromSelection: ->
        document.selection.createRange()

      # Get a range that surrounds the content of el.
      getRangeFromElement: (el) ->
        if el.nodeName == 'IMG'
          range = document.body.createControlRange()
          range.add(el)
        else
          range = document.body.createTextRange()
          range.moveToElementText(el)
        range

    instance:
      #
      # HELPER FUNCTIONS
      #
      cloneRange: ->
        @range.duplicate()

      #
      # QUERY RANGE STATE FUNCTIONS
      #

      # Is the selection a caret.
      isCollapsed: ->
        @range.text.length == 0

      # Is an image selected.
      isImageSelected: ->
        typeof @range.parentElement == "undefined"

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
        (@range.parentElement and @range.parentElement()) or @range.item(0)

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

      # Select the given range or its own range if none given.
      select: (range) ->
        range or=@range
        range.select()
        @range = range
        this

      # Unselect the range.
      unselect: () ->
        document.selection.empty()

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
        @range.moveToElementText(el)
        # When getting text, <br> is replaced with /r/n (2 characters).
        # However, when moving by character the <br> is counted as a single
        # character. To get around this problem, we strip any \r before
        # counting.
        @range.moveStart("character", @range.text.replace(/\r/g, "").length)
        @range.collapse(true)
        @select()

      # Saves the range, executes the given fn, then reselects the range.
      # The function is given the start and end spans as arguments.
      #
      # NOTE: This inserts spans at the beginning and end of the range. These
      # cannot be removed. If they are, the reselection will fail. Be careful
      # what the given function does.
      keepRange: (fn) ->
        # Place spans at the start and end of the range.
        range = @constructor.getBlankRange()
        range.setEndPoint("StartToStart", @range)
        range.collapse(true)
        range.pasteHTML('<span id="RANGE_START"></span>')
        range.setEndPoint("StartToEnd", @range)
        range.collapse(false)
        range.pasteHTML('<span id="RANGE_END"></span>')
        fn($("#RANGE_START")[0], $("#RANGE_END")[0])
        # Refind the start and end in case the function had modified them.
        $start = $("#RANGE_START")
        $end = $("#RANGE_END")
        range.moveToElementText($start[0])
        @range.setEndPoint("StartToStart", range)
        range.moveToElementText($end[0])
        @range.setEndPoint("EndToStart", range)
        $start.remove()
        $end.remove()
        @select()

      #
      # MODIFY RANGE CONTENT FUNCTIONS
      #

      # Paste the given node and set the selection to after the node.
      #   text|
      #   <div>element</div>|
      #
      # NOTE: In W3C, we manually need to move the caret. In IE, the pasteHTML
      # method automatically moves the caret to after the end of the pasted
      # node.
      #
      # NOTE: In IE, the pasted node is a copy of the node given.  In W3C, the
      # actual node is pasted in. Although I can normalize this, in some special
      # cases, we may need access to that node for W3C only
      # so I have not removed reference-ability in W3C. 
      pasteNode: (node) ->
        div = document.createElement("div")
        div.appendChild(node)
        @pasteHTML(div.innerHTML)

      # Paste HTML and set the selection to after the HTML.
      #   text|
      #   <div>element</div>|
      #
      # NOTE: In W3C, we manually need to move the caret. In IE, the pasteHTML
      # method automatically moves the caret to after the end of the pasted
      # node.
      #
      # NOTE: IE attempts to be too smart when placing the selection after
      # pasting elements. It does not always go after the elements. Furthermore,
      # IE7 behave differently in certain situations.
      # Inline element (not <a>):
      #   If the pasted element has content and there's no content afterwards,
      #   the selection always goes at the end of the inside of the element.
      #     <span>test|</span>
      #   If the pasted element has content and there's content afterwards, it
      #   depends on the IE version.
      #     IE7: <span>test|<span>after
      #     IE8: <span>test</span>|after
      #   If the pasted element has no content, it depends on what's around.
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
      pasteHTML: (html) ->
        # In IE7, in order for the selection to be placed after the pasted node
        # automatically, the range must be selected first. There is no harm in
        # leaving this in for other versions.
        @select()
        @range.pasteHTML(html)

      # Surround range with element and place the selection after the element.
      surroundContents: (el) ->
        el.innerHTML = @range.htmlText
        @pasteNode(el)

      # Delete the contents of the range.
      delete: ->
        @select()
        [startElement, endElement] = @getParentElements((el) -> Helpers.isBlock(el))
        deleted = $(startElement).closest("td, th", @el)[0] == $(endElement).closest("td, th", @el)[0]
        @range.execCommand("delete") if deleted
        return deleted
  }
