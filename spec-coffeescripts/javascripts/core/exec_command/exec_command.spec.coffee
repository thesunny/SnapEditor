# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
 require ["jquery.custom", "core/exec_command/exec_command", "core/range", "core/helpers"], ($, ExecCommand, Range, Helpers) ->
  describe "ExecCommand", ->
    $editable = execCommand = null
    beforeEach ->
      $editable = addEditableFixture()
      execCommand = new ExecCommand()
      execCommand.editor =
        doc: document
        win: window
        el: $editable[0]
        find: (selector) -> $(@doc).find(selector).toArray()
        getRange: -> new Range($editable[0], window)
        getBlankRange: -> new Range($editable[0])
        isValid: -> true
        config: atomic: selectors: [".atomic"]
      Helpers.delegate(execCommand.editor, "getRange()", "getParentElement", "getParentElements", "isCollapsed", "unselect", "insert")
      Helpers.delegate(execCommand.editor, "getBlankRange()", "select", "selectElementContents", "selectEndOfElement")

    afterEach ->
      $editable.remove()

    describe "#formatInline", ->
      it "bolds given 'bold'", ->
        $div = $("<div>some text</div>").appendTo($editable)
        new Range($editable[0], $div[0]).select()
        execCommand.formatInline("bold")
        if isIE
          expect(clean($div.html())).toEqual("<strong>some text</strong>")
        else
          expect($div.html()).toEqual("<b>some text</b>")

      it "italicizes given 'italic'", ->
        $div = $("<div>some text</div>").appendTo($editable)
        new Range($editable[0], $div[0]).select()
        execCommand.formatInline("italic")
        if isIE
          expect(clean($div.html())).toEqual("<em>some text</em>")
        else
          expect($div.html()).toEqual("<i>some text</i>")

      if isGecko
        it "styles without CSS in Gecko", ->
          spyOn(execCommand, "exec")
          execCommand.formatInline("b")
          expect(execCommand.exec.argsForCall[0]).toEqual(["styleWithCSS", false])

    describe "#align", ->
      describe "collapsed", ->
        # NOTE: IE7/8 specs seem to crap out when the thing to be aligned is the
        # first or last element of the editable area. Hence, we sandwich
        # everything with a before and after div.
        setupAlign = (html) ->
          $editable.html("<div>before</div>#{html}<div>after</div>")
          $align = $editable.find("#align")
          range = new Range($editable[0])
          if hasW3CRanges
            range.range.setStart($align[0].childNodes[0], 1)
          else
            range.range.findText("lign me")
          range.collapse(true)
          range.select()
          $align

        it "adds a text-align style to the parent block", ->
          $align = setupAlign('<div>this is some text <span id="align">align me</span>some more text</div>')
          expect(execCommand.align("center")).toBeTruthy()
          expect($editable.find("div").first().attr("style")).toBeUndefined()
          expect($align.parent().attr("style").replace(/;/, "")).toEqual("text-align: center")
          expect($editable.find("div").last().attr("style")).toBeUndefined()

        it "adds a text-align style to the parent div tag", ->
          $align = setupAlign('<div id="align">align me</div>')
          expect(execCommand.align("center")).toBeTruthy()
          expect($editable.find("div").first().attr("style")).toBeUndefined()
          expect($align.attr("style").replace(/;/, "")).toEqual("text-align: center")
          expect($editable.find("div").last().attr("style")).toBeUndefined()

        it "adds a text-align style to the parent p tag", ->
          $align = setupAlign('<p>before</p><p id="align">align me</p><p>after</p>')
          expect(execCommand.align("center")).toBeTruthy()
          expect($editable.find("div").first().attr("style")).toBeUndefined()
          expect($align.attr("style").replace(/;/, "")).toEqual("text-align: center")
          expect($editable.find("div").last().attr("style")).toBeUndefined()

        it "adds a text-align style to the parent h1 tag", ->
          $align = setupAlign('<h1>before</h1><h1 id="align">align me</h1><h1>after</h1>')
          expect(execCommand.align("center")).toBeTruthy()
          expect($editable.find("div").first().attr("style")).toBeUndefined()
          expect($align.attr("style").replace(/;/, "")).toEqual("text-align: center")
          expect($editable.find("div").last().attr("style")).toBeUndefined()

        it "adds a text-align style to the parent th tag", ->
          $align = setupAlign('<table><tbody><tr><th>before</th><th id="align">align me</th><th>after</th></tr></tbody></table>')
          expect(execCommand.align("center")).toBeTruthy()
          expect($editable.find("div").first().attr("style")).toBeUndefined()
          expect($align.attr("style").replace(/;/, "")).toEqual("text-align: center")
          expect($editable.find("div").last().attr("style")).toBeUndefined()

        it "adds a text-align style to the parent td tag", ->
          $align = setupAlign('<table><tbody><tr><td>before</td><td id="align">align me</td><td>after</td></tr></tbody></table>')
          expect(execCommand.align("center")).toBeTruthy()
          expect($editable.find("div").first().attr("style")).toBeUndefined()
          expect($align.attr("style").replace(/;/, "")).toEqual("text-align: center")
          expect($editable.find("div").last().attr("style")).toBeUndefined()

        it "modifies the text-align style", ->
          $align = setupAlign('<div id="align">align me</div>')
          expect(execCommand.align("center")).toBeTruthy()
          expect($align.attr("style").replace(/;/, "")).toEqual("text-align: center")
          expect(execCommand.align("right")).toBeTruthy()
          expect($editable.find("div").first().attr("style")).toBeUndefined()
          expect($align.attr("style").replace(/;/, "")).toEqual("text-align: right")
          expect($editable.find("div").last().attr("style")).toBeUndefined()

        it "doesn't touch atomic elements", ->
          $align = setupAlign('<div class="atomic">atomic</div><div id="align">align me</div>')
          expect(execCommand.align("center")).toBeTruthy()
          expect($editable.find(".atomic").attr("style")).toBeUndefined()
          expect($align.attr("style").replace(/;/, "")).toEqual("text-align: center")

      describe "uncollapsed", ->
        # NOTE: IE7/8 specs seem to crap out when the thing to be aligned is the
        # first or last element of the editable area. Hence, we sandwich
        # everything with a before and after div.
        setupAlign = (html) ->
          $editable.html("<div>before</div>#{html}<div>after</div>")
          range = new Range($editable[0])
          if hasW3CRanges
            range.range.setStart($("#start")[0].childNodes[0], 0)
            range.range.setEnd($("#end")[0].childNodes[0], 3)
          else
            range.range.findText("start")
            endRange = Range.getBlankRange()
            endRange.findText("end")
            range.range.setEndPoint("EndToEnd", endRange)
          range.select()

        it "aligns blocks that are selected", ->
          setupAlign("""
            <div id="start">start</div>
            <p>paragraph</p>
            <h1>header</h1>
            <div id="end">end</div>
          """)
          expect(execCommand.align("right")).toBeTruthy()
          expect($editable.find("div").first().attr("style")).toBeUndefined()
          expect($("#start").attr("style").replace(/;/, "")).toEqual("text-align: right")
          expect($editable.find("p").attr("style").replace(/;/, "")).toEqual("text-align: right")
          expect($editable.find("h1").attr("style").replace(/;/, "")).toEqual("text-align: right")
          expect($("#end").attr("style").replace(/;/, "")).toEqual("text-align: right")
          expect($editable.find("div").last().attr("style")).toBeUndefined()

        it "doesn't touch atomic elements", ->
          setupAlign("""
            <div class="atomic">atomic</div>
            <div id="start">start</div>
            <div id="end">end</div>
          """)
          expect(execCommand.align("right")).toBeTruthy()
          expect($editable.find("div").first().attr("style")).toBeUndefined()
          expect($editable.find(".atomic").attr("style")).toBeUndefined()
          expect($("#start").attr("style").replace(/;/, "")).toEqual("text-align: right")
          expect($("#end").attr("style").replace(/;/, "")).toEqual("text-align: right")
          expect($editable.find("div").last().attr("style")).toBeUndefined()

        describe "table", ->
          it "doesn't align table cells when selecting across a table", ->
            setupAlign("""
              <div id="start">start</div>
              <table><tbody>
                <tr><th>1.1</th><th>1.2</th></tr>
                <tr><td>2.1</td><td>2.2</td></tr>
              </tbody></table>
              <div id="end">end</div>
            """)
            expect(execCommand.align("right")).toBeTruthy()
            expect($editable.find("div").first().attr("style")).toBeUndefined()
            expect($("#start").attr("style").replace(/;/, "")).toEqual("text-align: right")
            expect($editable.find("th").first().attr("style")).toBeUndefined()
            expect($editable.find("th").last().attr("style")).toBeUndefined()
            expect($editable.find("td").first().attr("style")).toBeUndefined()
            expect($editable.find("td").last().attr("style")).toBeUndefined()
            expect($("#end").attr("style").replace(/;/, "")).toEqual("text-align: right")
            expect($editable.find("div").last().attr("style")).toBeUndefined()

          it "doesn't align anything when ending in a table cell", ->
            setupAlign("""
              <div id="start">start</div>
              <table><tbody>
                <tr><th>1.1<span id="end">end</span></th><th>1.2</th></tr>
                <tr><td>2.1</td><td>2.2</td></tr>
              </tbody></table>
            """)
            expect(execCommand.align("right")).toBeFalsy()
            expect($editable.find("div").first().attr("style")).toBeUndefined()
            expect($("#start").attr("style")).toBeUndefined()
            expect($editable.find("th").first().attr("style")).toBeUndefined()
            expect($editable.find("div").last().attr("style")).toBeUndefined()

          it "doesn't align anything when starting in a table cell", ->
            setupAlign("""
              <table><tbody>
                <tr><th>1.1</th><th>1.2</th></tr>
                <tr><td>2.1<span id="start">start</span></td><td>2.2</td></tr>
              </tbody></table>
              <div id="end">end</div>
            """)
            expect(execCommand.align("right")).toBeFalsy()
            expect($editable.find("div").first().attr("style")).toBeUndefined()
            expect($editable.find("td").first().attr("style")).toBeUndefined()
            expect($editable.find("td").last().attr("style")).toBeUndefined()
            expect($("#end").attr("style")).toBeUndefined()
            expect($editable.find("div").last().attr("style")).toBeUndefined()

          it "doesn't align anything when starting and ending in different table cells", ->
            setupAlign("""
              <table><tbody>
                <tr><th>1.1<span id="start">start</span></th><th>1.2</th></tr>
                <tr><td>2.1</td><td>2.2<span id="end">end</span></td></tr>
              </tbody></table>
            """)
            expect(execCommand.align("right")).toBeFalsy()
            expect($editable.find("div").first().attr("style")).toBeUndefined()
            expect($editable.find("th").first().attr("style")).toBeUndefined()
            expect($editable.find("th").last().attr("style")).toBeUndefined()
            expect($editable.find("td").first().attr("style")).toBeUndefined()
            expect($editable.find("td").last().attr("style")).toBeUndefined()
            expect($editable.find("div").last().attr("style")).toBeUndefined()

          it "aligns the table cell when starting and ending in the same table cell", ->
            setupAlign("""
              <table><tbody>
                <tr><th><span id="start">start</span>1.1<span id="end">end</span></th><th>1.2</th></tr>
                <tr><td>2.1</td><td>2.2<span id="end">end</span></td></tr>
              </tbody></table>
            """)
            expect(execCommand.align("right")).toBeTruthy()
            expect($editable.find("div").first().attr("style")).toBeUndefined()
            expect($editable.find("th").first().attr("style").replace(/;/, "")).toEqual("text-align: right")
            expect($editable.find("th").last().attr("style")).toBeUndefined()
            expect($editable.find("td").first().attr("style")).toBeUndefined()
            expect($editable.find("td").last().attr("style")).toBeUndefined()
            expect($editable.find("div").last().attr("style")).toBeUndefined()

    describe "#insertLink", ->
      $link = range = $div = insertedLinks = $a = null
      beforeEach ->
        $link = $('<a href="http://snapeditor.com/test" target="_blank"></a>')

      describe "caret in text", ->
        beforeEach ->
          $div = $("<div>some text</div>").appendTo($editable)
          range = new Range($editable[0])
          if hasW3CRanges
            range.range.setEnd($div[0].childNodes[0], 4)
          else
            range.range.findText("some")
          range.collapse(false).select()
          insertedLinks = execCommand.insertLink($link[0])
          $a = $div.find("a")

        it "inserts the link", ->
          expect(clean($div.html())).toEqual("some<a href=http://snapeditor.com/test target=_blank>http://snapeditor.com/test</a> text")

        it "returns the inserted links", ->
          expect(insertedLinks.length).toEqual(1)
          expect(insertedLinks[0]).toBe($a[0])

        #it "places the selection at the end of the last link", ->
          #range = new Range($editable[0], window)
          #expect(range.getParentElement()).toBe($a[0])

      describe "caret in link", ->
        beforeEach ->
          $div = $('<div>some <a href="http://snapeditor.com/exists">link</a> text</div>').appendTo($editable)
          range = new Range($editable[0])
          if hasW3CRanges
            range.range.setStart($div.find("a")[0].childNodes[0], 1)
          else
            range.range.findText("ink")
          range.collapse(true).select()
          insertedLinks = execCommand.insertLink($link[0])
          $a = $div.find("a")

        it "modifies the link", ->
          expect(clean($div.html())).toEqual("some <a href=http://snapeditor.com/test target=_blank>link</a> text")

        it "returns the inserted links", ->
          expect(insertedLinks.length).toEqual(1)
          expect(insertedLinks[0]).toBe($a[0])

        #it "places the selection at the end of the last link", ->
          #range = new Range($editable[0], window)
          #expect(range.getParentElement()).toBe($a[0])

      describe "selecting text only", ->
        beforeEach ->
          $div = $("<div>some text</div>").appendTo($editable)
          range = new Range($editable[0])
          if hasW3CRanges
            range.range.setStart($div[0].childNodes[0], 0)
            range.range.setEnd($div[0].childNodes[0], 4)
          else
            range.range.findText("some")
          range.select()
          insertedLinks = execCommand.insertLink($link[0])
          $a = $div.find("a")

        it "inserts the link", ->
          expect(clean($div.html())).toEqual("<a href=http://snapeditor.com/test target=_blank>some</a> text")

        it "returns the inserted links", ->
          expect(insertedLinks.length).toEqual(1)
          expect(insertedLinks[0]).toBe($a[0])

        #it "places the selection at the end of the last link", ->
          #range = new Range($editable[0], window)
          #expect(range.getParentElement()).toBe($a[0])

      describe "selecting across inline elements", ->
        $div = insertedLinks = $a = null
        beforeEach ->
          $div = $("<div>some <b>text <i>with</i> elements</b> in it</div>").appendTo($editable)
          range = new Range($editable[0])
          if hasW3CRanges
            range.range.setStart($div[0].childNodes[0], 2)
            range.range.setEnd($div[0].childNodes[1].childNodes[2], 5)
          else
            range.range.findText("me text with elem")
          range.select()
          insertedLinks = execCommand.insertLink($link[0])
          $a = $div.find("a")

        it "inserts the link", ->
          expect(clean($div.html())).toEqual("so<a href=http://snapeditor.com/test target=_blank>me </a><b><a href=http://snapeditor.com/test target=_blank>text <i>with</i> elem</a>ents</b> in it")

        it "returns the inserted links", ->
          expect(insertedLinks.length).toEqual(2)
          expect(insertedLinks[0]).toBe($a[0])
          expect(insertedLinks[1]).toBe($a[1])

        #it "places the selection at the end of the last link", ->
          #range = new Range($editable[0], window)
          #expect(range.getParentElement()).toBe($a[1])

      describe "selecting across block elements", ->
        $start = $end = null
        beforeEach ->
          $start = $("<div>start text</div>").appendTo($editable)
          $end = $("<div>end text</div>").appendTo($editable)
          range = new Range($editable[0])
          if hasW3CRanges
            range.range.setStart($start[0].childNodes[0], 2)
            range.range.setEnd($end[0].childNodes[0], 7)
          else
            range.range.findText("art text")
            endRange = new Range($editable[0])
            endRange.range.findText("end tex")
            range.range.setEndPoint("EndToEnd", endRange.range)
          range.select()
          insertedLinks = execCommand.insertLink($link[0])
          $a = $editable.find("a")

        it "inserts the link", ->
          expect(clean($editable.html())).toEqual("<div>st<a href=http://snapeditor.com/test target=_blank>art text</a></div><div><a href=http://snapeditor.com/test target=_blank>end tex</a>t</div>")

        it "returns the inserted links", ->
          expect(insertedLinks.length).toEqual(2)
          expect(insertedLinks[0]).toBe($a[0])
          expect(insertedLinks[1]).toBe($a[1])

        #it "places the selection at the end of the last link", ->
          #range = new Range($editable[0], window)
          #expect(range.getParentElement()).toBe($a[1])

      describe "image", ->
        $img = null
        beforeEach ->
          $editable.html("<img src=\"http://#{document.location.host}/spec/javascripts/support/assets/images/stub.png\" />")
          $img = $editable.find("img")
          range = new Range($editable[0], $img[0])
          range.select()
          insertedLinks = execCommand.insertLink($link[0])
          $a = $editable.find("a")

        it "inserts the link", ->
          expect(clean($editable.html())).toEqual("<a href=http://snapeditor.com/test target=_blank><img src=http://#{document.location.host}/spec/javascripts/support/assets/images/stub.png></a>")

        it "returns the inserted links", ->
          expect(insertedLinks.length).toEqual(1)
          expect(insertedLinks[0]).toBe($a[0])

        #it "places the selection at the end of the last link", ->
          #range = new Range($editable[0], window)
          #expect(range.getParentElement()).toBe($a[0])

      describe "link", ->
        $existingLink = null
        beforeEach ->
          $editable.html('<a href="http://snapeditor.com/exist">exist</a>')
          $existingLink = $editable.find("a")
          range = new Range($editable[0], $existingLink[0])
          range.select()
          insertedLinks = execCommand.insertLink($link[0])
          $a = $editable.find("a")

        it "modifies the existing link", ->
          expect(clean($editable.html())).toEqual("<a href=http://snapeditor.com/test target=_blank>exist</a>")

        it "returns the inserted links", ->
          expect(insertedLinks.length).toEqual(1)
          expect(insertedLinks[0]).toBe($a[0])

        #it "places the selection at the end of the last link", ->
          #range = new Range($editable[0], window)
          #expect(range.getParentElement()).toBe($a[0])

      describe "partial link", ->
        $existingLink = null
        beforeEach ->
          $editable.html('before <a href="http://snapeditor.com/exist">exist</a> after')
          $existingLink = $editable.find("a")
          range = new Range($editable[0])
          if hasW3CRanges
            range.range.setStart($existingLink[0].childNodes[0], 3)
            range.range.setEnd($editable[0].childNodes[2], 3)
          else
            range.range.findText("st aft")
          range.select()

        it "modifies the link when the selection starts inside a link", ->
          insertedLinks = execCommand.insertLink($link[0])
          $a = $editable.find("a")
          expect(clean($editable.html())).toEqual("before <a href=http://snapeditor.com/test target=_blank>exist</a> after")

        it "modifies the link when the selection ends inside a link", ->
          if hasW3CRanges
            range.range.setStart($editable[0].childNodes[0], 3)
            range.range.setEnd($existingLink[0].childNodes[0], 3)
          else
            range.range.findText("ore exi")
          range.select()
          insertedLinks = execCommand.insertLink($link[0])
          $a = $editable.find("a")
          expect(clean($editable.html())).toEqual("before <a href=http://snapeditor.com/test target=_blank>exist</a> after")

        it "returns the inserted links", ->
          insertedLinks = execCommand.insertLink($link[0])
          $a = $editable.find("a")
          expect(insertedLinks.length).toEqual(1)
          expect(insertedLinks[0]).toBe($a[0])

        #it "places the selection at the end of the last link", ->
          #insertedLinks = execCommand.insertLink($link[0])
          #$a = $editable.find("a")
          #range = new Range($editable[0], window)
          #expect(range.getParentElement()).toBe($a[0])
