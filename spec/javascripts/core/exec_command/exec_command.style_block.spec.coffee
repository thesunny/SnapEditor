require ["jquery.custom", "core/exec_command/exec_command.style_block"], ($, StyleBlock) ->
  describe "ExecCommand.StyleBlock", ->
    $editable = null
    beforeEach ->
      $editable = addEditableFixture()

    afterEach ->
      $editable.remove()

    describe "#getElementsBetween", ->
      it "returns only a single element", ->
        $editable.html("<p>paragraph</p>")
        $p = $editable.find("p")
        els = StyleBlock.getElementsBetween($p[0], $p[0], $editable[0])
        expect(els.length).toEqual(1)
        expect(els[0]).toBe($p[0])

      it "gets all elements at the top level", ->
        $editable.html("""
          <p>paragraph</p>
          <h1>heading 1</h1>
          <ul><li>1</li><li>2</li></ul>
          <table>
            <tr><td>1.1</td><td>1.2</td></tr>
            <tr><td>2.1</td><td>2.2</td></tr>
          </table>
          <p>another <b>paragraph</b></p>
          <div>div</div>
        """)
        $children = $editable.children()
        els = StyleBlock.getElementsBetween($children[0], $children[4], $editable[0])
        expect(els.length).toEqual(5)
        expect(els[0]).toBe($children[0])
        expect(els[1]).toBe($children[1])
        expect(els[2]).toBe($children[2])
        expect(els[3]).toBe($children[3])
        expect(els[4]).toBe($children[4])

      it "handles starting in a list", ->
        $editable.html("""
          <ul><li>1</li><li>2</li></ul>
          <p>paragraph</p>
          <h1>heading 1</h1>
          <table>
            <tr><td>1.1</td><td>1.2</td></tr>
            <tr><td>2.1</td><td>2.2</td></tr>
          </table>
          <p>another <b>paragraph</b></p>
          <div>div</div>
        """)
        $children = $editable.children()
        els = StyleBlock.getElementsBetween($editable.find("li")[0], $children[4], $editable[0])
        expect(els.length).toEqual(5)
        expect(els[0]).toBe($children[0])
        expect(els[1]).toBe($children[1])
        expect(els[2]).toBe($children[2])
        expect(els[3]).toBe($children[3])
        expect(els[4]).toBe($children[4])

      it "handles ending in a list", ->
        $editable.html("""
          <p>paragraph</p>
          <h1>heading 1</h1>
          <table>
            <tr><td>1.1</td><td>1.2</td></tr>
            <tr><td>2.1</td><td>2.2</td></tr>
          </table>
          <p>another <b>paragraph</b></p>
          <ul><li>1</li><li>2</li></ul>
          <div>div</div>
        """)
        $children = $editable.children()
        els = StyleBlock.getElementsBetween($children[0], $editable.find("li")[0], $editable[0])
        expect(els.length).toEqual(5)
        expect(els[0]).toBe($children[0])
        expect(els[1]).toBe($children[1])
        expect(els[2]).toBe($children[2])
        expect(els[3]).toBe($children[3])
        expect(els[4]).toBe($children[4])

      it "handles starting and ending in the same table", ->
        $editable.html("""
          <table>
            <tr><td>1.1</td><td>1.2</td></tr>
            <tr><td>2.1</td><td>2.2</td></tr>
          </table>
        """)
        $tds = $editable.find("td")
        els = StyleBlock.getElementsBetween($tds[1], $tds[3], $editable[0])
        expect(els.length).toEqual(3)
        expect(els[0]).toBe($tds[1])
        expect(els[1]).toBe($tds[2])
        expect(els[2]).toBe($tds[3])

      it "handles staring in a table", ->
        $editable.html("""
          <table>
            <tr><td>1.1</td><td>1.2</td></tr>
            <tr><td>2.1</td><td>2.2</td></tr>
          </table>
          <p>paragraph</p>
          <h1>heading 1</h1>
          <p>another <b>paragraph</b></p>
          <ul><li>1</li><li>2</li></ul>
          <div>div</div>
        """)
        $children = $editable.children()
        $tds = $editable.find("td")
        els = StyleBlock.getElementsBetween($tds[1], $children[4], $editable[0])
        expect(els.length).toEqual(7)
        expect(els[0]).toBe($tds[1])
        expect(els[1]).toBe($tds[2])
        expect(els[2]).toBe($tds[3])
        expect(els[3]).toBe($children[1])
        expect(els[4]).toBe($children[2])
        expect(els[5]).toBe($children[3])
        expect(els[6]).toBe($children[4])

      it "handles ending in a table", ->
        $editable.html("""
          <p>paragraph</p>
          <h1>heading 1</h1>
          <p>another <b>paragraph</b></p>
          <ul><li>1</li><li>2</li></ul>
          <table>
            <tr><td>1.1</td><td>1.2</td></tr>
            <tr><td>2.1</td><td>2.2</td></tr>
          </table>
          <div>div</div>
        """)
        $children = $editable.children()
        $tds = $editable.find("td")
        els = StyleBlock.getElementsBetween($children[0], $tds[2], $editable[0])
        expect(els.length).toEqual(7)
        expect(els[0]).toBe($children[0])
        expect(els[1]).toBe($children[1])
        expect(els[2]).toBe($children[2])
        expect(els[3]).toBe($children[3])
        expect(els[4]).toBe($tds[0])
        expect(els[5]).toBe($tds[1])
        expect(els[6]).toBe($tds[2])

      it "handles starting and ending in different tables", ->
        $editable.html("""
          <table>
            <tr><td>1.1</td><td>1.2</td></tr>
            <tr><td>2.1</td><td>2.2</td></tr>
          </table>
          <p>paragraph</p>
          <h1>heading 1</h1>
          <p>another <b>paragraph</b></p>
          <ul><li>1</li><li>2</li></ul>
          <table>
            <tr><td>1.1</td><td>1.2</td></tr>
            <tr><td>2.1</td><td>2.2</td></tr>
          </table>
          <div>div</div>
        """)
        $children = $editable.children()
        $tds = $editable.find("td")
        els = StyleBlock.getElementsBetween($tds[1], $tds[6], $editable[0])
        expect(els.length).toEqual(10)
        expect(els[0]).toBe($tds[1])
        expect(els[1]).toBe($tds[2])
        expect(els[2]).toBe($tds[3])
        expect(els[3]).toBe($children[1])
        expect(els[4]).toBe($children[2])
        expect(els[5]).toBe($children[3])
        expect(els[6]).toBe($children[4])
        expect(els[7]).toBe($tds[4])
        expect(els[8]).toBe($tds[5])
        expect(els[9]).toBe($tds[6])

    describe "#getCells", ->
      $tds = null
      beforeEach ->
        $editable.html("""
          <table>
            <tr><td>1.1</td><td>1.2</td></tr>
            <tr><td>2.1</td><td>2.2</td></tr>
          </table>
        """)
        $tds = $editable.find("td")

      it "returns the start cell and all the next cells", ->
        cells = StyleBlock.getCells(true, $tds[1])
        expect(cells.length).toEqual(3)
        expect(cells[0]).toBe($tds[1])
        expect(cells[1]).toBe($tds[2])
        expect(cells[2]).toBe($tds[3])

      it "returns the start cell and all the next cells up to and including the end cell", ->
        cells = StyleBlock.getCells(true, $tds[1], $tds[2])
        expect(cells.length).toEqual(2)
        expect(cells[0]).toBe($tds[1])
        expect(cells[1]).toBe($tds[2])

      it "returns the start cell and all the previous cells", ->
        cells = StyleBlock.getCells(false, $tds[2])
        expect(cells.length).toEqual(3)
        expect(cells[0]).toBe($tds[0])
        expect(cells[1]).toBe($tds[1])
        expect(cells[2]).toBe($tds[2])

      it "returns the start cell and all the previous cells up to and including the end cell", ->
        cells = StyleBlock.getCells(false, $tds[2], $tds[1])
        expect(cells.length).toEqual(2)
        expect(cells[0]).toBe($tds[1])
        expect(cells[1]).toBe($tds[2])
