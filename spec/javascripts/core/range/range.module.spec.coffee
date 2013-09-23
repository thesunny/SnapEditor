# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
describe "Range.Module", ->
  required = ["core/range/range.module"]

  ait "returns a Module object", required, (Module) ->
    expect(Module).not.toBeNull()
    expect(Module.static).toBeDefined()
    expect(Module.instance).toBeDefined()
