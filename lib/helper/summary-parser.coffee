path = require 'path'
fs = require 'fs-plus'

module.exports =
class SummaryParser
  @instances = {}

  @getInstance: (directory) ->
    @instances[directory] ?= new SummaryParser(directory)

  constructor: (directory) ->
    @loadFromFile(directory)

  loadFromFile: (directory) ->
    @tree = []

    @lastFile = @getFullFilepath(directory) if directory? or not @lastFile?

    unless @lastFile?
      return

    contents = fs.readFileSync(@lastFile, 'utf-8')
    @parseFileToTree(contents)

  reload: ->
    @loadFromFile()

  getFullFilepath: (directory) ->
    if fs.existsSync(path.join(directory, 'summary.md'))
      name = directory + '/summary.md'
    else if fs.existsSync(path.join(directory, '/SUMMARY.md'))
      name = directory + '/SUMMARY.md'

    return name or false

  addSection: (name, path, parent) ->
    toWrite = {name: name, file: path, indent: 0}
    toWriteIndex = @tree.length

    for ele, idx in @tree
      if parent? and ele.file == parent
        toWriteIndex = idx + 1
        toWrite.indent = ele.indent + 2

    @tree.splice toWriteIndex, 0, toWrite
    @tree

  deleteSection: (filename) ->
    for ele, idx in @tree
      # Occasionally the tree gets borked?
      if ele? and ele.file == filename
        @tree.splice idx, 1
    @tree

  parseFileToTree: (contents) ->
    re = new RegExp /[\n\r]*(\s*)?\*\s+?\[([^\]]+?)\]\((.+?)\)/gi

    while (arr = re.exec(contents)) != null
      indent = 0
      indent = arr[1].length if arr[1]

      treeObj = indent: indent, name: arr[2], file: arr[3]

      @tree.push(treeObj)

  generateFileFromTree: (file) ->
    file = @lastFile if not file?

    lines = []
    for ele in @tree
      line = "* [#{ele.name}](#{ele.file})"
      if ele.indent > 0
        for i in [1..ele.indent]
          line = " " + line
      lines.push(line)

    linestr = lines.join("\n")

    fs.writeFileSync(file, linestr)
