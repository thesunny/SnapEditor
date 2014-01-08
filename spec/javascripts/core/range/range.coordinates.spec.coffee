# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
require ["core/range/range.coordinates"], (Coordinates) ->
  describe "Range.Coordinates", ->
    required = ["core/range/range.coordinates"]

    it "returns a Coordinates object", ->
      expect(Coordinates).not.toBeNull()
      expect(Coordinates.getCoordinates).toBeDefined()
