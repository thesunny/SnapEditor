# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
 if isGecko
   require ["jquery.custom", "core/exec_command/exec_command.gecko", "core/range", "core/helpers"], ($, Module, Range, Helpers) ->
    describe "ExecCommand.Gecko", ->
      $editable = execCommand = null
      beforeEach ->
        $editable = addEditableFixture()
        class ExecCommand
          rangeExec: (command) -> document.execCommand(command, false, null)
        Helpers.include(ExecCommand, Module)
        execCommand = new ExecCommand()
        execCommand.editor =
          createElement: (tag) -> document.createElement(tag)
          getRange: -> new Range($editable[0], window)
        Helpers.delegate(execCommand.editor, "getRange()", "getParentElements")

      afterEach ->
        $editable.remove()

      describe "#indent", ->
        # NOTE: This spec craps out once in a while depending on the order of
        # the tests. I have tracked this down to a clash with
        # empty_handler.spec.coffee. When #deleteAll() is called, it inserts a
        # default block and selects the end of it. It is the call to
        # #selectEndOfElement() that craps this spec out. I'm not sure why it
        # breaks but I don't think it's worth it at this time to try and fix
        # this. Indenting of lists seem to work properly when actually using
        # the editor.
        it "indents a top level list with a single item", ->
          $editable.html("<ul><li>test</li></ul>")
          range = new Range($editable[0])
          range.range.setStart($editable.find("li")[0].childNodes[0], 0)
          range.collapse(true).select()
          expect(execCommand.indent()).toBeTruthy()
          expect(clean($editable.html())).toEqual("<ul><ul><li>test</li></ul></ul>")
