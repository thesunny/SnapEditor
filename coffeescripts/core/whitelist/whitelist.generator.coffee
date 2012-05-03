# This generates the following whitelists given the whtielist:
# * defaults
# * whitelistByLabel
# * whitelistByTag
#
# The values are stored as objects with the following keys:
# * tag
# * classes (sorted alphabetically)
# * next
#
# All labels are dereferenced to their objects.
define [], ->
  class Generator
    constructor: (@whitelist) ->

    getDefaults: ->
      @generateWhitelists() unless @defaults
      return @defaults

    getWhitelistByLabel: ->
      @generateWhitelists() unless @whitelistByLabel
      return @whitelistByLabel

    getWhitelistByTag: ->
      @generateWhitelists() unless @whitelistByTag
      return @whitelistByTag

    generateWhitelists: ->
      @all = []
      @defaults = {}
      @whitelistByLabel = {}
      @whitelistByTag = {}
      for label, value of @whitelist
        if @isLabel(label)
          obj = @parse(value)
          @all.push(obj)
          @whitelistByLabel[label] = obj
          # Add to the whitelist by tag.
          @whitelistByTag[obj.tag] = [] unless @whitelistByTag[obj.tag]
          @whitelistByTag[obj.tag].push(obj)
        else
          unless @isLabel(value)
            throw "Whitelist default '#{label}: #{value}' must reference a label"
          @defaults[label] = value
      # Labels that appear as values are not dereferenced above. This is
      # because the dereferenced label may not exist yet. Hence we need to call
      # normalize.
      @normalize()

    # Run through all the whitelists and dereference any labels.
    normalize: ->
      @defaults[label] = @whitelistByLabel[value] for label, value of @defaults
      for obj in @all
        obj.next = @whitelistByLabel[obj.next] if typeof obj.next == "string"

    isLabel: (label) ->
      !!label.match(/^[A-Z]/)

    parse: (string) ->
      [element, next] = (s.trim() for s in string.split(">"))
      [tag, classes...] = (s.trim() for s in element.split("."))
      next = @parse(next) if next and !@isLabel(next)
      return {
        tag: tag
        classes: classes.sort()
        next: next
      }

  return Generator
