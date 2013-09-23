# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom", "core/exec_command/exec_command.gecko", "core/browser", "core/helpers", "core/exec_command/exec_command.style_block"], ($, Gecko, Browser, Helpers, StyleBlock) ->
  class ExecCommand
    constructor: (@editor) ->

    # Calls document.execCommand().
    exec: (cmd, value = null) ->
      @editor.doc.execCommand(cmd, false, value)

    # This differs from #exec() in that it requires a range to perform the
    # execCommand. This will check whether the range is valid before performing
    # the execCommand.
    # Returns true if the command was allowed. False otherwise.
    rangeExec: (cmd, value = null) ->
      valid = @editor.isValid()
      @exec(cmd, value) if valid
      return valid

    # Styles the block with the given style.
    # Style consists of a tag followed by classes delimited by '.'.
    # e.g. h1.title.xlarge
    styleBlock: (style) ->
      StyleBlock.style(style, @editor)

    # Formats the selection with the given tag.
    # Returns true if the command was allowed. False otherwise.
    formatInline: (type) ->
      allowed = @editor.isValid()
      if allowed
        # Gecko defaults to styling with CSS. We want to disable that.
        # NOTE: This disables styling with CSS for the entire document, not just
        # for this editor.
        @exec("styleWithCSS", false) if Browser.isGecko
        @exec(type)
      return allowed

    # Aligns the text given how: left, centre/center, right, justify/full.
    #
    # NOTE:
    # Only Webkit and Gecko offer CSS styling for alignment. IE provides only
    # attributes for alignment.
    #
    # NOTE:
    # There are many edge cases when selecting into tables.
    # 1. When selecting across an entire table, all browsers do not align any
    #    of the cells.
    # 2. When the selection ends inside a table, some of the browsers will
    #    align the cells while others will not.
    # 3. When the selection start inside a table, some of the browsers will
    #    align the cells while others will not.
    # 4. When the selection starts and ends in different cells, some of the
    #    browsers will align the cells while others will not.
    # Due to these differences, it was very hard to stay consistent. Hence, if
    # the selection doesn't start and end in the same cell, we disallow
    # alignment. This may seem restrictive, but it's also pretty ridiculous to
    # do this from the user's perspective.
    align: (how) ->
      how = "center" if how == "centre"
      how = "full" if how == "justify"
      allowed = true
      # Only allow alignment in tables if the selection starts and ends in the
      # same table cell.
      unless @editor.isCollapsed()
        [startCell, endCell] = @editor.getParentElements("td, th")
        allowed = startCell == endCell
      if allowed
        # It is possible that styling with CSS has been turned off. We make sure
        # that we turn on CSS styling so we get style="text-align: left" instead
        # of align="left".
        @exec("styleWithCSS", true) if Browser.isGecko
        allowed = @rangeExec("justify#{Helpers.capitalize(how)}")
        # IE adds alignment using align="left" instead of style="text-align:
        # left". To fix this, we allow IE to do its thing and then look for
        # all the places it inserted align="left" and change it so that it uses
        # style="text-align" instead. There is one odd case which is for table
        # cells. IE wraps the content in a <p> and adds the alignment on the
        # <p>. Hence, if the alignment element is inside a table cell, we apply
        # style="text-align: left" on the table cell instead.
        if allowed and Browser.isIE
          self = this
          $(@editor.find("*[align]")).each(->
            $alignEl = $(this)
            # Since we're grabbing all elements with the align attribute, we
            # may be dealing with atomic elements too. However, since they're
            # atomic, we don't actually want to change them. Therefore, we
            # skip any elements that are atomic. Unfortunately, this is a hack
            # since execCommand shouldn't actually know about atomic, but this
            # part of the code is already a hack and it's the simplest way to
            # do this.
            if $alignEl.closest(self.editor.config.atomic.selectors.join(",")).length == 0
              align = $alignEl.attr("align")
              # Align the parent table cell instead if it exists.
              $cell = $alignEl.parent("td, th")
              $alignEl = $cell if $cell.length > 0
              $alignEl.css("text-align", align)
              $(this).removeAttr("align")
          )
      allowed

    # Add an indent.
    # Returns true if the command was allowed. False otherwise.
    indent: ->
      @rangeExec("indent")

    # Add an outdent.
    # Returns true if the command was allowed. False otherwise.
    outdent: ->
      @rangeExec("outdent")

    # Insert an unordered list.
    # Returns true if the command was allowed. False otherwise.
    insertUnorderedList: ->
      allowed = @allowList()
      @exec("insertunorderedlist") if allowed
      return allowed

    # Insert an ordered list.
    # Returns true if the command was allowed. False otherwise.
    insertOrderedList: ->
      allowed = @allowList()
      @exec("insertorderedlist") if allowed
      return allowed

    # Insert a horizontal rule.
    insertHorizontalRule: ->
      @rangeExec("inserthorizontalrule")

    # Insert the given link element.
    # It is possible that several links are created. Therefore, this returns an
    # array of inserted links. If insertion fails, an empty array is returned.
    insertLink: (link) ->
      insertedLinks = []
      $link = $(link)

      # If the selection starts or ends inside a link, we change the
      # selection to select the link so that "createLink" modifies the link.
      [startParent, endParent] = @editor.getParentElements("a")
      @editor.selectElementContents(startParent || endParent) if startParent || endParent

      # When the range is collapsed, the "createLink" execCommand does nothing.
      # A selection must be made in order for "createLink" to insert a link.
      # The only browser that inserts a link when the range is collapsed is
      # Webkit. However, we don't make a special case for Webkit because the
      # collpased code still works.
      if @editor.isCollapsed()
        # Save the id in case the link has one.
        id = $link.attr("id")
        # Use our own id for inserting and finding.
        $link.attr("id", "SNAPEDITOR_INSERTED_LINK")
        $link.html($link.attr("href"))
        @editor.insert($link[0])
        $insertedLink = $(@editor.find("#SNAPEDITOR_INSERTED_LINK"))
        # Restore or remove the id.
        if id
          $insertedLink.attr("id", id)
        else
          $insertedLink.removeAttr("id")
        insertedLinks.push($insertedLink[0])
      else
        # "createLink" does not allow you to add any attributes to the link.
        # This includes ids and classes. In order to find the inserted link, we
        # use the href. We insert a randomly generated href, look for it, then
        # modify it using the given link.
        randomHref = "http://snapeditor.com/#{Math.floor(Math.random() * 99999)}"
        if @rangeExec("createLink", randomHref)
          # It is possible for "createLink" to insert multiple links.
          $a = $(@editor.find("a[href=\"#{randomHref}\"]"))
          $a.each((index) ->
            insertedLinks.push($link.clone()[0])
            $(this).replaceElementWith(insertedLinks[index])
          )
      # TODO: Not sure where to place the selection yet. Figure this out.
      # If links were inserted, places the selection at the end of the last link.
      @editor.selectEndOfElement(insertedLinks[insertedLinks.length - 1]) if insertedLinks.length > 0
      return insertedLinks

    # Returns true if block formatting is allowed. False otherwise.
    allowFormatBlock: ->
      return false unless @editor.isValid()
      allowed = !@editor.getParentElement("table, li")
      alert("Sorry. This action cannot be performed inside a table or list.") unless allowed
      return allowed

    # Returns true if list formatting is allowed. False otherwise.
    allowList: ->
      return false unless @editor.isValid()
      allowed = !@editor.getParentElement("table")
      alert("Sorry. This action cannot be performed inside a table.") unless allowed
      return allowed

  Helpers.include(ExecCommand, Gecko) if Browser.isGecko

  return ExecCommand
