define ["jquery.custom"], ($, Browser, Helpers) ->
  class Print
    register: (@api) ->

    getUI: (ui) ->
      print = ui.button(action: "print", description: @api.lang.print, icon: { url: @api.assets.image("printer.png"), width: 24, height: 24, offset: [3, 3] })
      return {
        "toolbar:default": "print"
        print: print
      }

    getActions: ->
      return {
        print: @print
      }

    # Can't override ctrl+p in IE.
    #getKeyboardShortcuts: ->
      #return {
        #"ctrl.p": "print"
      #}

    print: =>
      printWin = window.open("","_blank","width=1000,height=650,left=400,top=100,menubar=yes,toolbar=no,location=no,scrollbars=yes")
      printWin.document.open()
      printWin.document.write('<!doctype html><html><head><title>SnapEditor Print</title>')
      $.each(@api.find("link, style"), ->
        printWin.document.write(this.outerHTML)
      )
      printWin.document.write('</head><body onload="print();">')
      printWin.document.write(@api.getContents())
      printWin.document.write('</body></html>')
      printWin.document.close()
