# TODO

## Important for Markup Editor

* [x] PRE or code support exceptions in cleaner
* [x] Disallow tags in pre (allow RANGE elements)
* [x] Enter inside PRE should add a newline only
* [ ] IE9+IE10 bug where you can start typing at the end of a line in a PRE and
      it jumps down to the next line. This appears to be because the cursor can be after the newline character but before the actual next line.
      When you start typing there, your text then ends up as part of the
      next line. This is my guess why this is happening.
* [ ] Join multiple pre tags together if they are next to each other in Cleaner
* [ ] nested blockquote support in cleaner
* [ ] blocks at top level within blockquotes in cleaner

    h1:
      nested: false   # no nesting
    blockquote:
      nested: true    # unlimited nesting
    div.container:
      nested: 1       # 1 level of nesting


## Semantics and Language

Americanize spelling

  behaviour -> behaviour

Make configuration use def and undef like

    defBehavior
    undefBehavior

In instance configuration use

  addBehaviors: [...],
  removeBehaviors: [...]
  toolbar: []