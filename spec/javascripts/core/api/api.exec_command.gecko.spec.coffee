 if isGecko
   require ["jquery.custom", "core/api/api.exec_command.gecko", "core/range", "core/helpers"], ($, Module, Range, Helpers) ->
    describe "API.ExecCommand.Gecko", ->
      $editable = execCommand = null
      beforeEach ->
        $editable = addEditableFixture()
        class ExecCommand
          rangeExec: (command) -> document.execCommand(command, false, null)
        Helpers.include(ExecCommand, Module)
        execCommand = new ExecCommand()
        execCommand.api =
          createElement: (tag) -> document.createElement(tag)
          getRange: -> new Range($editable[0], window)
        Helpers.delegate(execCommand.api, "getRange()", "getParentElements")

      afterEach ->
        $editable.remove()

      describe "#indent", ->
        it "indents a top level list with a single item", ->
          $editable.html("<ul><li>test</li></ul>")
          range = new Range($editable[0])
          range.range.setStart($editable.find("li")[0].childNodes[0], 0)
          range.collapse(true).select()
          expect(execCommand.indent()).toBeTruthy()
          expect(clean($editable.html())).toEqual("<ul><ul><li>test</li></ul></ul>")
