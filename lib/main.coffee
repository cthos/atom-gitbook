{CompositeDisposable} = require 'atom'
path = require 'path'
{$} = require 'atom-space-pen-views'
fs = require 'fs-plus'
{Emitter} = require 'atom'
IncludeParser = require './helper/include-parser'

if not atom.packages.isPackageDisabled 'markdown-preview'
  MarkdownPreviewView = require path.join(atom.packages.resolvePackagePath('markdown-preview'), 'lib', 'markdown-preview-view')

module.exports =
  config:
    removeFilesOnMenuDelete:
      type: 'string'
      default: 'No'
      enum : ['No', 'Yes', 'Ask']

  gitbookView: null

  activate: (@state) ->
    @emitter = new Emitter
    @subscriptions = new CompositeDisposable
    @createView()

    @state.attached ?= true if @shouldAutoOpen()
    @togglePanel() if @state.attached

    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-gitbook:toggle': => @togglePanel()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-gitbook:force-reload-toc': => @forceReloadToC()
    @subscriptions.add atom.commands.add '.gitbook-navigation-pane', 'atom-gitbook:new-chapter': => @newChapter()
    @subscriptions.add atom.commands.add '.gitbook-navigation-pane .gitbook-page-item', 'atom-gitbook:delete-chapter': => @deleteChapter()
    @subscriptions.add atom.commands.add '.tree-view.full-menu', 'atom-gitbook:add-file-as-chapter': => @addFileAsChapter()

    if not atom.packages.isPackageDisabled 'markdown-preview'
      @subscriptions.add atom.workspace.observeActivePaneItem (pane) => @observePane(pane)

  observePane: (pane) ->
    unless pane instanceof MarkdownPreviewView
      return

    pane.onDidChangeMarkdown =>
      return unless pane[0]
      replacedText = IncludeParser.parseIncludesInText(pane[0].innerHTML, pane.getPath())
      IncludeParser.rerenderMarkdown(replacedText, pane.getPath()).then (html) =>
        pane[0].innerHTML = html

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
    parser.generateFileFromTree()

    @createView().refresh()

  deleteChapter: ->
    @createView().deleteChapter()

  shouldAutoOpen: ->
    return false unless atom.project.getPaths()[0]?

    wsPath = atom.project.getPaths()[0]
    if fs.existsSync(path.join(wsPath, 'summary.md')) or fs.existsSync(path.join(wsPath, 'book.json'))
      return true

    false

  forceReloadToC: ->
    return unless @open
    @createView().refresh(true, true)

  togglePanel: ->
    if @open
      @createView().hide()
      @open = false
    else
      @createView().show()
      @createView().refresh(true)
      @open = true
