# TODO

## Important for Markup Editor

* [x] PRE or code support exceptions in cleaner
* [x] Disallow tags in pre (allow RANGE elements)
* [x] Enter inside PRE should add a newline only
* [x] Unit test handleNewline
* [ ] nested blockquote support in cleaner
* [ ] blocks at top level within blockquotes in cleaner
* [ ] Figure out some workaround for if the pre is the last thing that

Future PRE fixes
* [ ] IE9+IE10 bug where you can start typing at the end of a line in a PRE and
      it jumps down to the next line. This appears to be because the cursor can be after the newline character but before the actual next line.
      When you start typing there, your text then ends up as part of the
      next line. This is my guess why this is happening.
* [ ] Join multiple pre tags together if they are next to each other in Cleaner
* [ ] One day, when changing styles inside a PRE tag, have it only change the
      current line (i.e. between newlines)
* [ ] Don't allow tables inside PRE tags!
* [ ] Keydown in pre bottom of editing area should create a new P

Stuff To Do
* [ ] Add methods to Range that works in W3C and IE that takes an element
      and a character offset. Very useful for testing.
      range.move(el, 5)      # range is collapsed after 5th character of el
      range.moveStart(el, 5) # range start is moved after 5th character of el
      range.moveEnd(el, 5)   # range end is moved after 5th character of el


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