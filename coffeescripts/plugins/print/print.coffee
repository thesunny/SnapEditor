define ["jquery.custom", "plugins/helpers"], ($, Helpers) ->
  window.SnapEditor.internalCommands.print =
      Helpers.createCommand("print", "", (e) ->
        printWin = window.open("","_blank","width=1000,height=650,left=400,top=100,menubar=yes,toolbar=no,location=no,scrollbars=yes")
        printWin.document.open()
        printWin.document.write('<!doctype html><html><head><title>SnapEditor Print</title>')
        $.each(e.api.find("link, style"), ->
          printWin.document.write(@outerHTML)
        )
        printWin.document.write('</head><body onload="print();">')
        printWin.document.write(e.api.getContents())
        printWin.document.write('</body></html>')
        printWin.document.close()
      )
  window.SnapEditor.insertStyles("plugins_print", Helpers.createStyles("print", 25 * -26))
