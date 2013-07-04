# This generates the following whitelists given the whtielist:
# * defaults
# * byLabel
# * byTag
#
# The values are stored as Whitelist.Objects.
#
# All labels are dereferenced to their objects.
define ["jquery.custom", "core/whitelist/whitelist.object"], ($, WhitelistObject) ->
  class Whitelists
    constructor: (whitelist) ->
      @defaults = {}
      @byLabel = {}
      @byTag = {}
      @add(key, rule) for key, rule of whitelist

    # Returns a Whitelist.Object.
    getByDefault: (key) ->
      @byLabel[@defaults[key]]

    # Returns a Whitelist.Object.
    getByLabel: (label) ->
      @byLabel[label]

    # Returns an array of Whitelist.Object.
    getByTag: (tag) ->
      @byTag[tag]

    add: (key, rule) ->
      if @isLabel(key)
        prevObj = @byLabel[key]
        obj = @parse(rule)
        @byLabel[key] = obj
        # Add to the whitelist by tag.
        @byTag[obj.tag] or= []
        @byTag[obj.tag].push(obj)
        # Remove the previous object if there was one.
        @byTag[prevObj.tag].splice($.inArray(prevObj, @byTag[prevObj.tag]), 1) if prevObj
      else
        throw "Whitelist default '#{key}: #{rule}' must reference a label" unless @isLabel(rule)
        @defaults[key] = rule

    isLabel: (label) ->
      !!label.match(/^[A-Z0-9]/)

    # Parses the given string into a WhitelistObject.
    # e.g. h1#special-h1.title[data-json, style=(background|text-align)] > P
    parse: (rule) ->
      [element, next] = ($.trim(s) for s in rule.split(">"))
      [element, attrs] = ($.trim(s) for s in element.split("["))
      [element, classes...] = ($.trim(s) for s in element.split("."))
      [tag, id] = ($.trim(s) for s in element.split("#"))
      values = {}
      # Handle attributes if there are any.
      # Use [0..-2] to remove the trailing ']'.
      if attrs
        attrs = for s in attrs[0..-2].split(",")
          [attr, v] = $.trim(s).split("=(")
          # Handle values if there are any.
          # Use [0..-2] to remove the trailing ')'.
          values[attr] = ($.trim(s) for s in v[0..-2].split("|")) if v
          attr
      throw "Whitelist next '#{rule}' must reference a label" if next and !@isLabel(next)
      new WhitelistObject(tag, id, classes, attrs, values, next)
