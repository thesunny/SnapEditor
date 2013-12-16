# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
require ["jquery.custom", "plugins/cleaner/cleaner.flattener"], ($, Flattener) ->
  describe "Cleaner.Flattener", ->
    $editable = flattener = null
    beforeEach ->
      $editable = addEditableFixture()
      flattener = new Flattener([".ignore", ".ignore2"])

    afterEach ->
      $editable.remove()

    describe "#flattenBlock", ->
      it "replaces the block with its children when the block is not special", ->
        $editable.html("<div>this is some text</div>")
        flattener.flattenBlock($editable.find("div")[0])
        expect(clean($editable.html())).toEqual("this is some text")

      it "replaces the list with the list item contents and <br>s between", ->
        $editable.html("<ol><li>first</li><li>second</li></ol>")
        flattener.flattenBlock($editable.find("ol")[0], $("<br/>"))
        children = $editable[0].childNodes
        expect(children.length).toEqual(3)
        expect(children[0].nodeValue).toEqual("first")
        expect($(children[1]).tagName()).toEqual("br")
        expect(children[2].nodeValue).toEqual("second")

      it "replaces the table with the cell item contents and <br>s between", ->
        $editable.html("<table><tbody><tr><th>1.1</th><th>1.2</th></tr><tr><td>2.1</td><td>2.2</td></tr></tbody></table>")
        flattener.flattenBlock($editable.find("table")[0], $("<br/>"))
        children = $editable[0].childNodes
        expect(children.length).toEqual(7)
        expect(children[0].nodeValue).toEqual("1.1")
        expect($(children[1]).tagName()).toEqual("br")
        expect(children[2].nodeValue).toEqual("1.2")
        expect($(children[3]).tagName()).toEqual("br")
        expect(children[4].nodeValue).toEqual("2.1")
        expect($(children[5]).tagName()).toEqual("br")
        expect(children[6].nodeValue).toEqual("2.2")

    describe "#flattenListItem", ->
      it "takes all the children, makes them list items, and replaces the original list item", ->
        $editable.html("<ul><li><p>Here's a block</p><div>Here's another</div></li></ul>")
        flattener.flattenListItem($editable.find("li")[0])
        $lis = $editable.find("li")
        expect($lis.length).toEqual(2)
        expect($lis[0].innerHTML).toEqual("Here's a block")
        expect($lis[1].innerHTML).toEqual("Here's another")

      it "takes a list and moves it out of the li", ->
        $editable.html("<ul><li>first</li><li><ol><li>inner</li><li>list</li></ol></li></ul>")
        flattener.flattenListItem($editable.find("li")[1])
        $ul = $editable.find("ul")
        expect($ul.children("li").length).toEqual(1)
        $ol = $ul.children("ol")
        expect($ol.length).toEqual(1)
        expect($ol.children("li").length).toEqual(2)

      it "takes a table, makes a list item per cell, and replaces the original list item", ->
        $editable.html("<ul><li><table><tbody><tr><th>1.1</th><th>1.2</th></tr><tr><td>2.1</td><td>2.2</td></tr></tbody></table></li></ul>")
        flattener.flattenListItem($editable.find("li")[0])
        $lis = $editable.find("li")
        expect($lis.length).toEqual(4)
        expect($lis[0].innerHTML).toEqual("1.1")
        expect($lis[1].innerHTML).toEqual("1.2")
        expect($lis[2].innerHTML).toEqual("2.1")
        expect($lis[3].innerHTML).toEqual("2.2")

      it "takes a table to be ignored and moves the entire table as a whole", ->
        $editable.html('<ul><li><table class="ignore"><tbody><tr><th>1.1</th><th>1.2</th></tr><tr><td>2.1</td><td>2.2</td></tr></tbody></table></li></ul>')
        flattener.flattenListItem($editable.find("li")[0])
        $lis = $editable.find("li")
        expect($lis.length).toEqual(1)
        expect(clean($lis.first().html())).toEqual("<table class=ignore><tbody><tr><th>1.1</th><th>1.2</th></tr><tr><td>2.1</td><td>2.2</td></tr></tbody></table>")

      it "moves ignored elements as a whole", ->
        $editable.html('<ul><li><p>before</p><div class="ignore2"><p>ignore</p><p>this</p></div><div>after</div></li></ul>')
        flattener.flattenListItem($editable.find("li")[0])
        $lis = $editable.find("li")
        expect($lis.length).toEqual(3)
        expect($lis[0].innerHTML).toEqual("before")
        expect(clean($lis[1].innerHTML)).toEqual("<div class=ignore2><p>ignore</p><p>this</p></div>")
        expect($lis[2].innerHTML).toEqual("after")

    describe "#flattenTableCell", ->
      it "removes all blocks and places <br>s between them", ->
        $editable.html("<table><tbody><tr><td><p>this is a block</p><div>and another</div></td></tr></tbody></table>")
        flattener.flattenTableCell($editable.find("td")[0])
        children = $editable.find("td")[0].childNodes
        expect(children.length).toEqual(3)
        expect(children[0].nodeValue).toEqual("this is a block")
        expect($(children[1]).tagName()).toEqual("br")
        expect(children[2].nodeValue).toEqual("and another")

      it "removes all lists and places <br>s between the list items", ->
        $editable.html("<table><tbody><tr><td><ol><li>first</li></ol><ol><li>second</li></ol></td></tr></tbody></table>")
        flattener.flattenTableCell($editable.find("td")[0])
        children = $editable.find("td")[0].childNodes
        expect(children.length).toEqual(3)
        expect(children[0].nodeValue).toEqual("first")
        expect($(children[1]).tagName()).toEqual("br")
        expect(children[2].nodeValue).toEqual("second")

      it "removes all tables and places <br>s between each cell", ->
        $editable.html("<table><tbody><tr><td><table><tbody><tr><th>1</th></tr></tbody></table><table><tbody><tr><th>2</th></tr></tbody></table></td></tr></tbody></table>")
        flattener.flattenTableCell($editable.find("td")[0])
        children = $editable.find("td")[0].childNodes
        expect(children.length).toEqual(3)
        expect(children[0].nodeValue).toEqual("1")
        expect($(children[1]).tagName()).toEqual("br")
        expect(children[2].nodeValue).toEqual("2")

      it "does nothing to elements that should be ignored in the middle of the cell", ->
        $editable.html('<table><tbody><tr><td><p>text</p><div class="ignore"><p>ignore this</p></div><p>something</p><p>else</p><p class="ignore2">ignored</p><div>more text</div></td></tr></tbody></table>')
        flattener.flattenTableCell($editable.find("td")[0])
        expect(clean($editable.find("td").html())).toEqual("text<div class=ignore><p>ignore this</p></div>something<br>else<p class=ignore2>ignored</p>more text")

      it "does nothing to elements that should be ignored at the start and end of the cell", ->
        $editable.html('<table><tbody><tr><td><div class="ignore"><p>ignore this</p></div><p>text</p><p>something</p><p class="ignore2">ignored</p></td></tr></tbody></table>')
        flattener.flattenTableCell($editable.find("td")[0])
        expect(clean($editable.find("td").html())).toEqual("<div class=ignore><p>ignore this</p></div>text<br>something<p class=ignore2>ignored</p>")
