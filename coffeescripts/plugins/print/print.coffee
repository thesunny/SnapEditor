# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom", "plugins/helpers"], ($, Helpers) ->
  SnapEditor.actions.print = (e) ->
    printWin = window.open("","_blank","width=1000,height=650,left=400,top=100,menubar=yes,toolbar=no,location=no,scrollbars=yes")
    printWin.document.open()
    printWin.document.write('<!doctype html><html><head><title>SnapEditor Print</title>')
    $(e.api.doc).find("link, style").each( ->
      printWin.document.write(@outerHTML)
    )
    printWin.document.write('</head><body onload="print();">')
    printWin.document.write(e.api.getContents())
    printWin.document.write('</body></html>')
    printWin.document.close()
  SnapEditor.buttons.print = Helpers.createButton("print", "")
  SnapEditor.insertStyles("plugins_print", Helpers.createStyles("print", 25 * -26))
