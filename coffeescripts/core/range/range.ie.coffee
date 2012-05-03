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
      # QUERY RANGE STATE FUNCTIONS
      #

      # Is the selection a caret.
      isCollapsed: ->
        @range.text.length == 0

      # Is an image selected.
      isImageSelected: ->
        typeof @range.parentElement == "undefined"

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
      # TODO: Resurrect this function once we figure out how to get it to work.
      # The problem:
      # When selecting the element and collapsing to the end, the range falls
      # outside of the element.
      #   select: <div>|text</div>|
      #   collapse: <div>text</div>|
      # The range does not end up at the end of the inside of the element.
      # However, if it is a table cell, it does fall at the end of the inside
      # of the cell.
      #   select: <tr><td>|text|</td><td>more</td></tr>
      #   collapse: <tr><td>text|</td><td>more</td></tr>
      # This is why #selectEndOfTableCell() works, but the more
      # general case of any element doesn't.
      # If we can get this work, #selectEndOfTableCell() should call this.
      #selectEndOfElement: (el) ->
        #range = @constructor.getRangeFromElement(cell)
        #range.collapse(false)
        #@select(range)

      # Move selection to the end of a <td> or <th>.
      #
      # NOTE: This method is handled browser specific. In IE, collapsing the
      # range to the end places the caret in the inside of the end of the cell
      # so selecting the whole cell and moving the caret works. In W3C, the
      # caret needs to be placed at the end of the last child of the cell
      # manually.
      selectEndOfTableCell: (cell) ->
        range = @constructor.getRangeFromElement(cell)
        range.collapse(false)
        @select(range)

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

      # Remove the contents of the range.
      remove: ->
        @range.execCommand('delete')

  }
