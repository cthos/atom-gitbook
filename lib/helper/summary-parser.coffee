path = require 'path'
fs = require 'fs-plus'
slug = require 'slug'

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

  organizeFilesFromTree: (rootPath, file) ->
    lastIndent = 0;
    directory = basePath = atom.project.getPaths()[0]

    for ele, idx in @tree
      # TODO: Not quite right, doesn't cover situation where it jumps back up an indent level
      if ele.indent > lastIndent
        parentEl = @ensureEleFolderFormat(directory, basePath, previousElement)
        @tree[idx - 1] = parentEl

        parentPath = path.dirname(parentEl.file)
        directory = path.join(basePath, parentPath)

        newPath = path.join(parentPath, path.basename(ele.file))
        existingPath = path.join(directory, ele.file)
        ele.file = newPath

        # fs.moveSync(existingPath, path.join(directory, newPath)) if fs.statSync(existingPath).isFile()
      else if ele.indent > 0
        # reverse iterate over the tree until you find the common parent
        curpos = idx
        for i in [idx..0]
          continue unless @tree[i].indent < ele.indent

          parentPath = path.dirname(@tree[i].file)
          newPath = path.join(parentPath, path.basename(ele.file))
          ele.file = newPath
          break

      previousElement = ele
      lastIndent = ele.indent

    console.log @tree

  ensureEleFolderFormat: (rootPath, basePath, ele) ->
    return ele if path.basename(ele.file) == 'README.md'

    folderSlug = slug(path.basename(ele.file, 'md'), {replacement: "_", lower: true})
    folderPath = path.join(rootPath, folderSlug)

    # fs.mkdirSync(folderPath) unless fs.statSync(folderPath).isDirectory()
    filename = path.join(folderPath, 'README.md')

    existingPath = path.join(rootPath, ele.file)
    # fs.moveSync(existingPath, filename) if fs.statSync(existingPath).isFile()

    ele.file = path.relative(basePath, filename)
    ele
