path = require 'path'
fs = require 'fs-plus'

module.exports =
class SummaryParser
  @instances = {}

  @getInstance: (directory) ->
    @instances[directory] ?= new SummaryParser(directory)

  constructor: (directory) ->
    @directory = directory

    @loadFromFile(@directory)

  clearFileCache: ->
    @lastFile = null

  loadFromFile: (directory) ->
    @tree = []

    @lastFile = @getFullFilepath(directory) if directory? or not @lastFile?

    return unless @lastFile

    contents = fs.readFileSync(@lastFile, 'utf-8')
    @parseFileToTree(contents)

  reload: (clearFile) ->
    directory = if clearFile then @directory else null
    @loadFromFile(directory)

  getFullFilepath: (directory) ->
    jsonContents = @findAndParseBookJson(directory)
    summaryName = 'summary.md'

    if jsonContents and jsonContents.structure and jsonContents.structure.summary
      summaryName = jsonContents.structure.summary

    summaryPath = path.join(directory, summaryName)

    return false unless fs.existsSync(summaryPath)
    summaryPath

  findAndParseBookJson: (directory) ->
    bookPath = path.join(directory, 'book.json')

    return false unless fs.existsSync(bookPath)

    contents = fs.readFileSync(bookPath, 'utf-8')
    try
      parsedContents = JSON.parse(contents)
      return parsedContents
    catch error
      false


  addSection: (name, path, parent, index) ->
    toWrite = {name: name, file: path, indent: 0}
    toWriteIndex = if index? then index else @tree.length

    for ele, idx in @tree
      if parent? and ele.file == parent
        toWriteIndex = idx + 1
        toWrite.indent = ele.indent + 2

    # Check for children of new parent if index was passed
    if toWriteIndex > 0 and index
      prevEl = @tree[toWriteIndex - 1]
      if prevEl.indent
        toWrite.indent = prevEl.indent
      # Look for child elements until you don't find an indent
      while (nextEl = @tree[toWriteIndex])?
        if nextEl.indent <= toWrite.indent
          break
        toWriteIndex++

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
