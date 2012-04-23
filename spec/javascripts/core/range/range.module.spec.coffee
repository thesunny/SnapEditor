describe "Range.Module", ->
  required = ["core/range/range.module"]

  ait "returns a Module object", required, (Module) ->
    expect(Module).not.toBeNull()
    expect(Module.static).toBeDefined()
    expect(Module.instance).toBeDefined()
