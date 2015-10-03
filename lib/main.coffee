{CompositeDisposable} = require 'atom'
path = require 'path'
{$} = require 'atom-space-pen-views'
fs = require 'fs-plus'

module.exports =
  config:
    removeFilesOnMenuDelete:
      type: 'boolean'
      default: false
      title: 'Delete Files on Menu Removal'

  gitbookView: null

  activate: (@state) ->
    @subscriptions = new CompositeDisposable
    @createView()

    @state.attached ?= true if @shouldAutoOpen()
    @togglePanel() if @state.attached

    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-gitbook:toggle': => @togglePanel()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-gitbook:new-chapter': => @newChapter()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-gitbook:delete-chapter': => @deleteChapter()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-gitbook:add-file-as-chapter': => @addFileAsChapter()

  serialize: ->
    @state

  createView: ->
    unless @gitbookView?
      GitbookView = require './atom-gitbook-view'
      @gitbookView = new GitbookView
    @gitbookView # Return

  deactivate: ->
    @subscriptions.dispose()
    @gitbookView.destroy()

  newChapter: ->
    ChapterView = require './chapter-view'
    cv = new ChapterView()
    cv.attach()
    cv.onFileCreated =>
      @createView().refresh()

  addFileAsChapter: ->
    selectedFile = $('.tree-view .selected .name')

    return unless selectedFile[0]?

    file = selectedFile[0].dataset
    wsPath = atom.project.getPaths()[0]

    Parser = require './helper/summary-parser'
    parser = Parser.getInstance(wsPath)

    parser.addSection(file.name, path.relative(wsPath, file.path))
    @createView().refresh()

  deleteChapter: ->
    @createView().deleteChapter()

  shouldAutoOpen: ->
    wsPath = atom.project.getPaths()[0]
    if fs.existsSync(path.join(wsPath, 'summary.md')) or fs.existsSync(path.join(wsPath, 'book.json'))
      return true

    false

  togglePanel: ->
    if @open
      @gitbookView.hide()
      @open = false
    else
      @gitbookView.show()
      @open = true
