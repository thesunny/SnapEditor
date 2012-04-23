# This returns an object that contains static and instance functions. The
# expected usage is to extend a class with the static functions and to include 
# the instance functions.
#
# NOTE: IE9+ supports W3C ranges. Therefore, it uses this code. For IE7/8,
# please take a look at range.ie.coffee.

define ["jquery.custom", "core/helpers"], ($, Helpers) ->
  return {
    static:
      # Get a brand new range.
      getBlankRange: ->
        document.createRange()

      # Gets the currently selected range.
      getRangeFromSelection: ->
        # NOTE: The cloneRange is in response to some funky chicken where in
        # Firefox, manipulating the range object retrieved from a selection
        # object actually manipulates the selection! This became evident in the
        # EnterHandler where manipulating the range but still letting the
        # default enter handler to operate resulted in weird results like
        # duplicate fragments and stuff.
        window.getSelection().getRangeAt(0).cloneRange()

      # Get a range that surrounds the el.
      getRangeFromElement: (el) ->
        range = @getBlankRange()
        range.selectNode(el)
        range

    instance:
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
        div.childNodes.length == 1 && div.childNodes[0].tagName.toLowerCase(0) == "img"

      # Returns true if the current range is at the start of the given node.
      # We are at start of node if there are no width-generating characters.
      # This includes all characters except for newline, space and tab
      # However, &nbsp; does create a space which is why we can't use \S.
      #
      # NOTE: Only for W3C browsers. There is no corresponding IE function.
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
      isStartOfNode: (node) ->
        range = @range.cloneRange()
        range.setStartBefore(node)
        startText = $("<div/>").html(range.cloneContents()).text()
        startText.match(/^[\n\t ]*$/)

      # Returns true if the current range is at the end of the given node.
      # We are at ned of node if there are no width-generating characters.
      # This includes all characters except for newline, space and tab
      # However, &nbsp; does create a space which is why we can't use \S.
      #
      # NOTE: Only for W3C browsers. There is no corresponding IE function.
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
      # TODO: Remove the following comment once we remove the regex.
      # If there are only spaces until the end of node, we consider it end of
      # node.
      isEndOfNode: (node) ->
        range = @range.cloneRange()
        range.setEndAfter(node)
        endText = $("<div/>").html(range.cloneContents()).text()
        # TODO: Once we know for sure that it is safe to replace the following
        # regex, remove it.
        #!endText.match(/\S/)
        endText.match(/^[\n\t ]*$/)

      # Get immediate parent element.
      getImmediateParentElement: ->
        node = @range.commonAncestorContainer
        while !Helpers.isElement(node)
          node = node.parentNode
        node

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
        sel = window.getSelection()
        sel.removeAllRanges()
        sel.addRange(range)
        @range = range
        this

      # Unselects the range.
      unselect: ->
        window.getSelection().removeAllRanges()

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
        range = @constructor.getBlankRange()
        range.selectNodeContents(el)
        range.collapse(false)
        @select(range)
        # TODO: Figure out why this is here. Then add tests if applicable.
        @el.focus()

      # Move selection to the end of a <td> or <th>.
      #
      # NOTE: This method is handled browser specific. In IE, collapsing the
      # range to the end places the caret in the inside of the end of the cell
      # so selecting the whole cell and moving the caret works. In W3C, the
      # caret needs to be placed at the end of the last child of the cell
      # manually.
      selectEndOfTableCell: (cell) ->
        @selectEndOfElement(cell)

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
        div = document.createElement("div")
        div.innerHTML = html
        last = div.lastChild
        while(div.childNodes.length > 0 and node = div.childNodes[div.childNodes.length-1])
          @range.insertNode(node)
        @selectAfterElement(last)
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

      # Remove the contents of the range.
      remove: ->
        @range.deleteContents()
  }
