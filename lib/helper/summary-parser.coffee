path = require 'path'
fs = require 'fs-plus'

module.exports =
class SummaryParser
  constructor: (directory) ->
    @tree = []
    @deepestIndent = 0
    # TODO: Async calls
    if fs.existsSync(directory + '/summary.md')
      name = directory + '/summary.md'
    else if fs.existsSync(directory + '/SUMMARY.md')
      name = directory + '/SUMMARY.md'

    unless name?
      return

    contents = fs.readFileSync(name, 'utf-8')
    @parseFileToTree(contents)

  parseFileToTree: (contents) ->
    re = new RegExp /[\n\r]*(\s*)?\*\s+?\[([^\]]+?)\]\((.+?)\)/gi

    while (arr = re.exec(contents)) != null
      indent = 0
      indent = arr[1].length if arr[1]

      treeObj = indent: indent, name: arr[2], file: arr[3]

      @tree.push(treeObj)
