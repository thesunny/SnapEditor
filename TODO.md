# TODO

## Important for Markup Editor

* [x] PRE or code support exceptions in cleaner
* [x] Disallow tags in pre (allow RANGE elements)
* [x] Enter inside PRE should add a newline only
* [x] Unit test handleNewline
* [x] nested blockquote support in cleaner
* [x] blocks at top level within blockquotes in cleaner
* [x] Figure out some workaround for if the pre is the last thing that

* [ ] onReady callback
* [ ] A Markdown Editor should return a SnapEditor type of object, not this
      separate intermmediate object thingy
* [ ] setContent with markdown integration (behavior)
* [ ] getContent with markdown integration (behavior)
* [ ] Dashes "-" get escaped (backslash) in URLs, even after they've been
      submitted and re-read. Must be unnecessary or something else is going on.
* [ ] Backslashes in URLs multiple
* [ ] <P> tags are generated inside <li> tags right now. This is one reason
      why we get page shifting when the editor starts.
* [ ] Need to be able to pass options into Meditor Class!
* [ ] Don't allow deletion of block after a pre from inside the pre. In fact
      it probably doesn't make sense to allow any deletion from the end of
      pre. Just stop the action from happening. The only exception I can think
      of is to merge in another pre block.
* [ ] That first element (especially headings) having all that space in front
      of it is pretty annoying.
* [ ] Might be good to have ESC blur from the editor. Makes it easy to get to
      Vimium shortcuts.

Future PRE fixes
* [ ] IE9+IE10 bug where you can start typing at the end of a line in a PRE and
      it jumps down to the next line. This appears to be because the cursor can be after the newline character but before the actual next line.
      When you start typing there, your text then ends up as part of the
      next line. This is my guess why this is happening.
* [ ] Join multiple pre tags together if they are next to each other in Cleaner
* [ ] One day, when changing styles inside a PRE tag, have it only change the
      current line (i.e. between newlines)
* [ ] Don't allow tables inside PRE tags!
* [x] Keydown in pre bottom of editing area should create a new P. Used the
      table workaround instead which creates a block.

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