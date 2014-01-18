# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
#
# A blockquote has unique behaviors that need to be handled:
#
# * Atomic Deletes: When you delete a blockquote, you delete the whole thing
# * Nesting: Blockquotes may include other blockquotes
# * Block Container: Blockquotes may also include any other blocks that can
#   be included at the top level of the editor (e.g. p, h1, table, etc.)
#
# ## Blockquote indent behavior:
#
# A blockquote is created by using the blockquoteIndent action.
#
# This will turn all the blocks that encompass the selection into a blockquote.
#
# If the selection is already in a blockquote, it nest the new blockquote in
# the existing blockquote.
#
# ## Blockquote outdent behavior:
#
# A blockquote is removed by using the blockquoteOutdent action.
#
# 

define ["snapeditor.pre", "jquery.custom", "core/browser", "core/helpers"], (SnapEditor, $, Browser, Helpers) ->

  blockquote =
    # Blockquote has to account for the condition where the range traverses
    # multiple blocks.
    #
    # * Collapsed: blockquote the current block
    # * Expanded at same level: blockquote all selected
    # * Expanded at different levels in an existing blockquote: Treat any
    #   inner blockquote as a block. So even if it itself has multiple inner
    #   blocks and we are selecting some of them, we blockquote the whole
    #   thing. Seems like the expected behavior.
    indent: (e) ->
      [startEl, endEl] = e.api.getParentElements()
      commonParentEl = e.api.getParentElement() || e.api.el

      console.log startEl, endEl, commonParentEl

      if startEl != commonParentEl
        loop
          break if startEl.parentNode == commonParentEl
          startEl = startEl.parentNode
      if endEl != commonParentEl
        loop
          break if endEl.parentNode == commonParentEl
          endEl = endEl.parentNode

      blockquoteEl = e.api.doc.createElement "blockquote"

      elements = []
      currentEl = startEl
      elements.push currentEl
      loop
        break if !currentEl? or currentEl == endEl
        currentEl = currentEl.nextSibling
        elements.push currentEl

      $(startEl).before(blockquoteEl)

      for el in elements
        blockquoteEl.appendChild el

    # Blockquote outdent is a lot easier. Basically, all it does is that it
    # looks for the blockquote that the selection is in and then removes the
    # blockquote from it.
    outdent: (e) ->
      parentElement = e.api.getParentElement()
      parentBlockquote = $(parentElement).closest("blockquote", e.api.el)[0]
      if parentBlockquote
        e.api.keepRange ->
          Helpers.replaceWithChildren(parentBlockquote)

    setupBlockquote: (e) ->
      e.api.addWhitelistRule("Blockquote", "blockquote")

  SnapEditor.defActions
    blockquoteIndent: blockquote.indent
    blockquoteOutdent: blockquote.outdent

  SnapEditor.defButtons
    blockquoteIndent: Helpers.createButton("blockquoteIndent", null, onInclude: blockquote.setupBlockquote)
    blockquoteOutdent: Helpers.createButton("blockquoteOutdent", null, onInclude: blockquote.setupBlockquote)
