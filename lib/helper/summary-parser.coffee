{Emitter} = require 'atom'
path = require 'path'
fs = require 'fs-plus'
slug = require 'slug'
gitbookparse = require 'gitbook-parsers'

module.exports =
class SummaryParser
  @instances = {}

  @getInstance: (directory) ->
    @instances[directory] ?= new SummaryParser(directory)

  constructor: (directory) ->
    @emitter = new Emitter
    @directory = directory

    @loadFromFile(@directory)

  clearFileCache: ->
    @lastFile = null

  loadFromFile: (directory) ->
    @lastFile = @getFullFilepath(directory) if directory? or not @lastFile?

    return unless @lastFile

    @parser = gitbookparse.getForFile(@lastFile)

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
      if prevEl? and prevEl.indent
        toWrite.indent = prevEl.indent
      # Look for child elements until you don't find an indent
      while (nextEl = @tree[toWriteIndex])?
        if nextEl.indent <= toWrite.indent
          break
        toWriteIndex++

    @tree.splice toWriteIndex, 0, toWrite
    @tree


  onFileParsed: (callback) ->
    @emitter.on 'tree-parsing-complete', callback

  deleteSection: (filename) ->
    for ele, idx in @tree
      # Occasionally the tree gets borked?
      if ele? and ele.file == filename
        @tree.splice idx, 1
    @tree

  parseFileToTree: (contents) ->
    @parser.summary(contents).then (summary) =>
      @tree = []
      summary.chapters.forEach (chapter) =>
        @addToTree(chapter, 0)
        console.log "Emitting tree parse"
      @emitter.emit 'tree-parsing-complete'

  addToTree: (chapter, indent) ->
    treeObj = indent: indent, name: chapter.title, file: chapter.path

    @tree.push(treeObj)

    return if not chapter.articles

    chapter.articles.forEach (article) =>
      @addToTree(article, indent + 2)

  generateFileFromTree: (file) ->
    file = @lastFile if not file?

    lines = []
    for ele in @tree
      line = "* [#{ele.name}]"
      if ele.file
        line = line + "(#{ele.file})"
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
      ele.file = slug(ele.name, {replacement: "_", lower: true}) + '.md'
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
          oldPath = ele.file
          ele.file = newPath

          try
            fs.moveSync(oldPath, newPath) if fs.statSync(oldPath).isFile()

          break
      else if ele.indent == 0
        oldPath = ele.file
        directory = basePath

        try
          fs.moveSync(oldPath, ele.file) if fs.statSync(oldPath).isFile()

      previousElement = ele
      lastIndent = ele.indent

    @generateFileFromTree()

    # gitbook init if available and configured to do so? TODO: Finish and test
    # if atom.config.get('atom-gitbook.runGitbookInitAutomatically')
      # require('child-process').exec('gitbook init')

  ensureEleFolderFormat: (rootPath, basePath, ele) ->
    summaryFileName = atom.config.get('atom-gitbook.chapterSummaryFileName')
    return ele if path.basename(ele.file) == summaryFileName and path.dirname(ele.file) == basePath

    folderSlug = slug(path.basename(ele.file, 'md'), {replacement: "_", lower: true})
    folderPath = path.join(rootPath, folderSlug)

    try
      fs.statSync(folderPath).isDirectory()
    catch
      fs.mkdirSync(folderPath)

    filename = path.join(folderPath, summaryFileName)

    existingPath = path.join(rootPath, ele.file)
    try
      fs.moveSync(existingPath, filename) if fs.statSync(existingPath).isFile()

    ele.file = path.relative(basePath, filename)
    ele
