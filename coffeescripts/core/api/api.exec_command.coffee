define ["jquery.custom", "core/browser"], ($, Browser) ->
  class ExecCommand
    constructor: (@api) ->

    # Calls document.execCommand().
    exec: (cmd, value = null) ->
      @api.doc.execCommand(cmd, false, value)

    # This differs from #exec() in that it requires a range to perform the
    # execCommand. This will check whether the range is valid before performing
    # the execCommand.
    # Returns true if the command was allowed. False otherwise.
    rangeExec: (cmd, value = null) ->
      valid = @api.isValid()
      @exec(cmd, value) if valid
      return valid

    # Formats the block with the given tag.
    # Returns true if the command was allowed. False otherwise.
    formatBlock: (tag) ->
      # TODO-SH:
      # In Chrome, formatting a block with a p tag removes any span formatting
      # like bold and italic. May have to create a special version just for
      # webkit (Chrome and Safari).

      allowed = @allowFormatBlock()
      # IE required the angled brackets around the tag or it fails
      @exec("formatblock", "<#{tag}>") if allowed
      allowed

    # Formats the selection with the given tag.
    # Returns true if the command was allowed. False otherwise.
    formatInline: (tag) ->
      allowed = @api.isValid()
      if allowed
        # Gecko defaults to styling with CSS. We want to disable that.
        # NOTE: This disables styling with CSS for the entire document, not just
        # for this editor.
        @exec("styleWithCSS", false) if Browser.isGecko
        switch tag
          when "b" then @exec("bold")
          when "i" then @exec("italic")
          else throw "The inline style for tag #{tag} is unsupported"
      return allowed

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

    # Insert the given link element.
    # It is possible that several links are created. Therefore, this returns an
    # array of inserted links. If insertion fails, an empty array is returned.
    insertLink: (link) ->
      insertedLinks = []
      $link = $(link)

      # If the selection starts or ends inside a link, we change the
      # selection to select the link so that "createLink" modifies the link.
      [startParent, endParent] = @api.getParentElements("a")
      @api.selectNodeContents(startParent || endParent) if startParent || endParent

      # When the range is collapsed, the "createLink" execCommand does nothing.
      # A selection must be made in order for "createLink" to insert a link.
      # The only browser that inserts a link when the range is collapsed is
      # Webkit. However, we don't make a special case for Webkit because the
      # collpased code still works.
      if @api.isCollapsed()
        # Save the id in case the link has one.
        id = $link.attr("id")
        # Use our own id for inserting and finding.
        $link.attr("id", "SNAPEDITOR_INSERTED_LINK")
        $link.html($link.attr("href"))
        @api.paste($link[0])
        $insertedLink = $("#SNAPEDITOR_INSERTED_LINK")
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
          $a = $(@api.el).find("a[href=\"#{randomHref}\"]")
          $a.each((index) ->
            insertedLinks.push($link.clone()[0])
            $(this).replaceElementWith(insertedLinks[index])
          )
      # If links were inserted, select the contents of the first one.
      @api.selectEndOfElement(insertedLinks[insertedLinks.length - 1]) if insertedLinks.length > 0
      return insertedLinks

    # Returns true if block formatting is allowed. False otherwise.
    allowFormatBlock: ->
      return false unless @api.isValid()
      allowed = !@api.getParentElement("table, li")
      alert("Sorry. This action cannot be performed inside a table or list.") unless allowed
      return allowed

    # Returns true if list formatting is allowed. False otherwise.
    allowList: ->
      return false unless @api.isValid()
      allowed = !@api.getParentElement("table")
      alert("Sorry. This action cannot be performed inside a table.") unless allowed
      return allowed

  return ExecCommand
