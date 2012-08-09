# This returns an object that contains static and instance functions. The
# expected usage is to extend a class with the static functions and to include 
# the instance functions.
#
# NOTE: IE9+ supports W3C ranges. Therefore, it uses this code. For IE7/8,
# please take a look at range.ie.coffee.

define ["jquery.custom", "core/browser", "core/helpers"], ($, Browser, Helpers) ->
  return {
    static:
      # Get a brand new range.
      getBlankRange: (win = window) ->
        win.document.createRange()

      # Gets the currently selected range.
      getRangeFromSelection: (win = window) ->
        # NOTE: The cloneRange is in response to some funky chicken where in
        # Firefox, manipulating the range object retrieved from a selection
        # object actually manipulates the selection! This became evident in the
        # EnterHandler where manipulating the range but still letting the
        # default enter handler to operate resulted in weird results like
        # duplicate fragments and stuff.
        win.getSelection().getRangeAt(0).cloneRange()

      # Get a range that surrounds the el.
      getRangeFromElement: (el) ->
        range = @getBlankRange(Helpers.getWindow(el))
        range.selectNode(el)
        range

    instance:
      #
      # HELPER FUNCTIONS
      #
      cloneRange: ->
        @range.cloneRange()

      #
      # QUERY RANGE STATE FUNCTIONS
      #

      # Is the selection a caret.
      isCollapsed: ->
        @range.collapsed

      # Is an image selected.
      isImageSelected: ->
        div = $("<div/>").append(@range.cloneContents())[0]
        # An image is selected if it is the only content in the div.
        div.childNodes.length == 1 && div.childNodes[0].tagName && div.childNodes[0].tagName.toLowerCase(0) == "img"

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
        range = @cloneRange()
        range.setStartBefore(el)
        startText = $("<div/>").html(range.cloneContents()).text()
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
      #
      isEndOfElement: (el) ->
        range = @cloneRange()
        range.setEndAfter(el)
        endText = $("<div/>").html(range.cloneContents()).text()
        endText.match(Helpers.emptyRegExp)

      # Get immediate parent element.
      getImmediateParentElement: ->
        if @isImageSelected()
          # When an image is selected, the commonAncestorContainer is the
          # container of the image, not the image itself. Hence, we need to
          # find the image manually.
          node = @range.startContainer.childNodes[@range.startOffset]
        else
          node = @range.commonAncestorContainer
          while !Helpers.isElement(node)
            node = node.parentNode
        node

      # Get the text in the range.
      getText: ->
        @range.toString()

      # TODO: Confirm that this is no longer used. Remove the test if so.
      #getStartText: (match) ->
        #parent = @getParentElement(match)
        #range = @range.cloneRange()
        #range.setStartBefore(parent)
        #range.toString()

      # TODO: Confirm that this is no longer used. Remove the test if so.
      #getStart: (match) ->
        #parent = @getParentElement(match)
        #if parent
          #range = @range.cloneRange()
          #range.setStartBefore(parent)
          ## IMPORTANT:
          ## Chrome will represent the space as an HTML space character which is
          ## char code 160. When I look for things with a normal space in it, it
          ## won't match but the frickin' text looks like it matches exactly.
          ## Using a regexp to match a space via \s will work.
          #text = range.toString() #.replace(/\s/g, ' ')
          #start =
            #range: new @constructor(@el, range),
            #text: text
        #start

      # TODO: Confirm that this is no longer used
      # This method will replace getParentBlock(). It is used as part of a
      # formatBlock method which will bring together multiple fragments that
      # are not blocks as well. For example, a text node followed by a <b> node
      # followed by another text node.
      #getBlockFragment: ->
        #node = @range.commonAncestorContainer
        #finished = false
        #while !finished
          #if node.parent == @el
            #finished = true
          #else if node == @el or node == document.body 
            #finished = true
          #node = node.parent
        #node

      #
      # MANIPULATE RANGE FUNCTIONS
      #

      # Select the given range or its own range if none given.
      select: (range) ->
        range or= @range
        sel = @win.getSelection()
        sel.removeAllRanges()
        sel.addRange(range)
        @range = range
        this

      # Unselects the range.
      unselect: ->
        @win.getSelection().removeAllRanges()

      # Select the contents of the element.
      selectNodeContents: (el) ->
        @range.selectNodeContents(el)
        @select()

      # Move selection to the inside of the end of the element.
      #
      # NOTE: In W3C, the caret needs to be placed at the end of the last child
      # of the element manually.
      #
      # NOTE: The corresponding IE implementation is broken. This only works in
      # W3C.
      #
      # NOTE: In WebKit only, if the given element's innerHTML is empty, the
      # range will be set to the beginning of the closest textnode after the
      # element. If a textnode does not exist after the element, then the range
      # will be set to the end of the closest textnode before the element.
      #   <i></i> is the inserted node
      #   <body>before<i></i>|after<body>
      #   <body>before<i></i><div></div>|after</body>
      #   <body>before<i></i><div>|after</div></body>
      #   <body><div>before<i></i></div>|after</body>
      #   <body>before|<i></i></body>
      # Solutions tried and failed:
      # - If the element is empty, insert text, select it, then delete the text
      #   using range.deleteContents().
      # - If the element is empty, insert text, collapse the range, then delete
      #   the text using el.remove(el.childNodes[0]).
      # - If the element is empty, use range.setStart(el, 0) and
      #   range.setEnd(el, 0).
      selectEndOfElement: (el) ->
        @range.selectNodeContents(el)
        @range.collapse(false)
        @select()
        # TODO: Figure out why this is here. Then add tests if applicable.
        # This breaks IE9 as the focus scrolls the page so that the caret is
        # at the bottom of the page.
        @el.focus() unless Browser.isIE9

      # Place the selection after the element.
      #
      # NOTE: In WebKit only, it tries to be too smart with placing the range.
      # It seems like it is impossible to select right after an inline element
      # that has content, unless it is an <a>. This is fine with block elements
      # (even inline elements displayed as blocks). Also, if the inline element
      # does not have content, then the selection is before the closest
      # textnode after the node. If there is no textnode after the node, it is
      # after the last textnode before the node. This is similar behaviour to
      # #selectEndOfElement().
      #   Inline with content
      #     <span>inside|</span>after
      #     <b>inside|</b>after
      #   Inline without content
      #     before<span></span>|after
      #     before<b></b>|after
      #     before|<span></span>
      #   Anchor
      #     <a>inside</a>|after
      #   Block
      #     <div>inside</div>|after
      #     <p>inside</p>|after
      #     <span style="display:block">inside</p>|after
      # Solutions tried and failed:
      # - range.selectNode(node) then range.collapse(false)
      # - range.setStartAfter(node) and range.setEndAfter(node)
      # - grab the childNode index of the inserted node and then
      #   range.setStart(parentNode, index+1)
      # - range.setStart(node.nextSibling, 0)
      # Current solution:
      # Chose this because it is the simplest and at least works for blocks and
      # anchors.
      selectAfterElement: (el) ->
        @range.selectNode(el)
        @range.collapse(false)
        @select()

      # Saves the range, executes the given fn, then reselects the range.
      # The function is given the start and end spans as arguments.
      #
      # NOTE: This inserts spans at the beginning and end of the range. These
      # cannot be removed. If they are, the reselection will fail. Be careful
      # what the given function does.
      keepRange: (fn) ->
        # Place spans at the start and end of the range.
        $start = @createElement("span").attr("id", "RANGE_START")
        $end = @createElement("span").attr("id", "RANGE_END")
        # NOTE: Add the end span first because the insertion of the node is a
        # little weird when the selection is collapsed. If you add the start
        # span first, the end span will end up before the start span. By doing
        # the end span first, it shows up after the start span.
        end = @cloneRange()
        end.collapse(false)
        end.insertNode($end[0])
        start = @cloneRange()
        start.collapse(true)
        start.insertNode($start[0])
        fn($start[0], $end[0])
        # Refind the start and end in case the function had modified them.
        $start = @find("#RANGE_START")
        $end = @find("#RANGE_END")
        @range.setStart($start[0], 0)
        @range.setEnd($end[0], 0)
        # NOTE: When the spans are added, they split up textnodes. This causes
        # problems in Webkit. For example, when the range is at the beginning
        # of a list item and the textnodes were not merged back together,
        # calling indent/outdent through document.execCommand() would exhibit
        # crazy behaviour. Hence, we call normalize() on the parents to clean
        # up the textnodes.
        # NOTE: normalize() is called before removing the spans because in IE9,
        # if we call normalize() afterwards, it loses the range. However, if we
        # call normalize() before, it doesn't change IE9 and it fixes Webkit.
        $start.parent()[0].normalize()
        $end.parent()[0].normalize()
        $start.remove()
        $end.remove()
        @select()
        # TODO: Figure out if focus is absolutely needed for Gecko. If so, make
        # sure it is okay to add for Webkit too.
        #@el.focus()

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
      #
      # NOTE: This uses #selectAfterElement. In WebKit, there are problems when
      # the node is an inline element with content. Refer to
      # #selectAfterElement for details.
      pasteNode: (node) ->
        @range.insertNode(node)
        @selectAfterElement(node)

      # Paste HTML and set the selection to after the HTML.
      #   text|
      #   <div>element</div>|
      #
      # NOTE: In W3C, we manually need to move the caret. In IE, the pasteHTML
      # method automatically moves the caret to after the end of the pasted
      # node.
      #
      # NOTE: This uses #selectAfterElement. In WebKit, there are problems when
      # the node is an inline element with content. Refer to
      # #selectAfterElement for details.
      pasteHTML: (html) ->
        @select()
        div = @doc.createElement("div")
        div.innerHTML = html
        last = div.lastChild
        while(div.childNodes.length > 0 and node = div.childNodes[div.childNodes.length-1])
          @range.insertNode(node)
        @selectAfterElement(last)
        # TODO: Remove this once we know the above code works.
        #fragment = document.createDocumentFragment()
        #fragment.appendChild($("<p/>").append(html)[0])
        #@range.insertNode(fragment)

      # Surround range with element and place the selection after the element.
      #
      # NOTE: This uses #selectAfterElement. In WebKit, there are problems when
      # the node is an inline element with content. Refer to
      # #selectAfterElement for details.
      surroundContents: (el) ->
        @range.surroundContents(el)
        @selectAfterElement(el)

      # Delete the contents of the range.
      delete: ->
        @select()
        [startElement, endElement] = @getParentElements((el) -> Helpers.isBlock(el))
        deleted = $(startElement).closest("td, th", @el)[0] == $(endElement).closest("td, th", @el)[0]
        if deleted
          @keepRange((startEl, endEl) =>
            # We need to make sure the range is between and does not include the
            # span anchors or else we will lose the original range.
            @range.setStartAfter(startEl)
            @range.setEndBefore(endEl)
            @range.deleteContents()
            $(startElement).merge(endElement) if startElement != endElement
          )
        return deleted
  }
