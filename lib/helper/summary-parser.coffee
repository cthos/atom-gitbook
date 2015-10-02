path = require 'path'
fs = require 'fs-plus'

module.exports =
class SummaryParser
  constructor: (directory) ->
    @tree = []
    @deepestIndent = 0
    # TODO: Async calls

    name = @getFullFilepath(directory)

    unless name?
      return

    contents = fs.readFileSync(name, 'utf-8')
    @parseFileToTree(contents)

  getFullFilepath: (directory) ->
    if fs.existsSync(path.join(directory, 'summary.md'))
      name = directory + '/summary.md'
    else if fs.existsSync(path.join(directory, '/SUMMARY.md'))
      name = directory + '/SUMMARY.md'

    return name or false

  addSection: (name, path, parent) ->
    toWrite = {name: name, file: path, indent: 0}
    toWriteIndex = @tree.length

    for idx, ele in @tree
      if parent? and ele.file == parent
        toWriteIndex = idx + 1
        toWrite.indent = ele.indent + 2

    @tree.splice toWriteIndex, 0, toWrite
    @tree

  deleteSection: (filename) ->
    for idx, ele in @tree
      if ele.file == filename
        @tree.splice idx, 1

    @tree

  parseFileToTree: (contents) ->
    re = new RegExp /[\n\r]*(\s*)?\*\s+?\[([^\]]+?)\]\((.+?)\)/gi

    while (arr = re.exec(contents)) != null
      indent = 0
      indent = arr[1].length if arr[1]

      treeObj = indent: indent, name: arr[2], file: arr[3]

      console.log treeObj

      @tree.push(treeObj)

  generateFileFromTree: (directory) ->
    lines = []
    for ele in @tree
      line = "* [#{ele.name}](#{ele.file})"
      if ele.indent > 0
        for i in [1..ele.indent]
          line = " " + line
      lines.push(line)

    linestr = lines.join("\n")

    fs.writeFileSync(@getFullFilepath(directory), linestr)
