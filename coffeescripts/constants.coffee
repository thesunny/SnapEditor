define ->
  constants = {
    # These constants are used in exec_command.style_block so that it knows
    # which kind of styling it should do
    paragraphTags: ["div", "p", "h1", "h2", "h3", "h4", "h5", "h6", "pre"]
    listTags: ["ul", "ol", "li"]
    tableTags: ["table", "tr", "th", "td"]
  }
  constants.blockTags = constants.paragraphTags.concat(constants.listTags).concat(constants.tableTags)
  return constants
