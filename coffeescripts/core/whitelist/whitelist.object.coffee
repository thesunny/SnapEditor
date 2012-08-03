define ["jquery.custom", "core/browser"], ($, Browser) ->
  class WhitelistObject
    # Arguments:
    # * tag - the tagname of the element
    # * id - the id of the element
    # * classes - an array of classnames
    # * attrs - an array of allowed attribute names
    # * next - the whitelist object that should be inserted on enter
    constructor: (@tag, @id = null, @classes = [], attrs = [], @next) ->
      @classes = @classes.sort().join(" ")
      @attrs = {}
      @attrs[attr] = true for attr in attrs

    # If a template is given, the allowed attributes are copied.
    getElement: (doc, templateEl) ->
      $el = $(doc.createElement(@tag))
      # Add the classes if there are any.
      $el.attr("class", @classes) if @classes.length > 0
      # Copy the allowed attributes over from the template.
      ($el.attr(attr, $(templateEl).attr(attr)) for attr, value of @attrs) if templateEl
      return $el[0]

    # Returns true if the el matches.
    matches: (el) ->
      @tagMatches(el) and @idMatches(el) and @classesMatch(el) and @attributesAllowed(el)

    # Returns true if the tagnames match.
    tagMatches: (el) ->
      $(el).tagName() == @tag

    # Returns true if the ids match.
    idMatches: (el) ->
      id = $(el).attr("id")
      !@id and typeof id == "undefined" or @id == id

    # Returns true if the classes match.
    classesMatch: (el) ->
      ($(el).attr("class") or "").split(" ").sort().join(" ") == @classes

    # Returns true if all the attributes are allowed.
    # Ignores id and class.
    attributesAllowed: (el) ->
      for attr in el.attributes
        # IE7 loads the attributes array with both user and browser defined
        # attributes. Luckily, there is a specified field which will be false
        # for browser defined attributes which we can skip.
        continue if attr.name == "id" or attr.name == "class" or (Browser.isIE7 and !attr.specified)
        return false unless @attrs[attr.name]
      return true

  return WhitelistObject
