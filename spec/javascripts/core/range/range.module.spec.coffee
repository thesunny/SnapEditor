# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
require ["core/range/range.module"], (Module) ->
  describe "Range.Module", ->
    it "returns a Module object", ->
      expect(Module).not.toBeNull()
      expect(Module.static).toBeDefined()
      expect(Module.instance).toBeDefined()
