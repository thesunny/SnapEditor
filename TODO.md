# TODO

## Important

* PRE or code support exceptions in cleaner
* nested blockquote support in cleaner
* blocks at top level within blockquotes in cleaner

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