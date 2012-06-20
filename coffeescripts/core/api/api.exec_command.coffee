define ["core/browser"], (Browser) ->
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
