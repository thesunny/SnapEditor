# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
describe "Range.Coordinates", ->
  required = ["core/range/range.coordinates"]

  ait "returns a Coordinates object", required, (Coordinates) ->
    expect(Coordinates).not.toBeNull()
    expect(Coordinates.getCoordinates).toBeDefined()
