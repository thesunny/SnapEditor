require ["plugins/snap/snap"], (Snap) ->
  describe "Snap", ->
    $editable = api = snap = null
    beforeEach ->
      $editable = addEditableFixture().css(
        position: "absolute"
        top: 100
        left: 50
        height: 30
        width: 150
      )
      api = $("<div/>")
      api.el = $editable[0]
      snap = window.SnapEditor.internalPlugins.snap

    afterEach ->
      $editable.remove()

    describe "#setup", ->
      it "creates the snap divs", ->
        snap.setup()
        expect(snap.divs).not.toBeNull()
        expect(snap.divs.top).not.toBeNull()
        expect(snap.divs.bottom).not.toBeNull()
        expect(snap.divs.left).not.toBeNull()
        expect(snap.divs.right).not.toBeNull()

    describe "#getSnappedStyles", ->
      it "returns the styles of the snap divs after snapping so that they surround the element", ->
        elCoords =
          top: 100
          bottom: 1900
          left: 50
          right: 550
          width: 500
          height: 1000
        documentSize =
          x: 1000
          y: 3000
        styles = snap.getSnappedStyles(elCoords, documentSize)

        expect(styles.top.left).toEqual(50)
        expect(styles.top.width).toEqual(500)
        expect(styles.top.height).toEqual(100)

        expect(styles.bottom.top).toEqual(1900)
        expect(styles.bottom.left).toEqual(50)
        expect(styles.bottom.width).toEqual(500)
        expect(styles.bottom.height).toEqual(1100)

        expect(styles.left.width).toEqual(50)
        expect(styles.left.height).toEqual(3000)

        expect(styles.right.left).toEqual(550)
        expect(styles.right.width).toEqual(450)
        expect(styles.right.height).toEqual(3000)

    describe "#getUnsnappedStyles", ->
      it "returns the styles of the snap divs before they start snapping so that they are around the viewport", ->
        documentSize =
          x: 1000
          y: 3000
        portCoords =
          top: 50
          bottom: 1950
          left: 100
          right: 900
          width: 800
          height: 1000
        styles = snap.getUnsnappedStyles(documentSize, portCoords)

        expect(styles.top.left).toEqual(100)
        expect(styles.top.width).toEqual(800)
        expect(styles.top.height).toEqual(50)

        expect(styles.bottom.top).toEqual(1950)
        expect(styles.bottom.left).toEqual(100)
        expect(styles.bottom.width).toEqual(800)
        expect(styles.bottom.height).toEqual(1050)

        expect(styles.left.width).toEqual(100)
        expect(styles.left.height).toEqual(3000)

        expect(styles.right.left).toEqual(900)
        expect(styles.right.width).toEqual(100)
        expect(styles.right.height).toEqual(3000)
