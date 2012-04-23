describe "Range.Coordinates", ->
  required = ["core/range/range.coordinates"]

  ait "returns a Coordinates object", required, (Coordinates) ->
    expect(Coordinates).not.toBeNull()
    expect(Coordinates.getCoordinates).toBeDefined()
