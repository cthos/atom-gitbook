{CompositeDisposable} = require 'atom'
path = require 'path'

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

    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-gitbook:toggle': => @togglePanel()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-gitbook:new-chapter': => @newChapter()

  createView: ->
    unless @gitbookView?
      GitbookView = require './atom-gitbook-view'
      @gitbookView = new GitbookView
    @gitbookView # Return

  deactivate: ->
    @subscriptions.dispose()
    @gitbookView.destroy()

  newChapter: ->
    console.log "New Chapter invoked"
    ChapterView = require './chapter-view'
    new ChapterView().attach();

  togglePanel: ->
    if @open
      @gitbookView.hide()
      @open = false
    else
      @gitbookView.show()
      @open = true
