NavPane = require './nav-pane'
fs = require 'fs-plus'
path = require 'path'

module.exports =
class AtomGitbookView
  constructor: (serializedState) ->

  getNavPane: ->
    if not @navPane?
      @navPane = new NavPane
    @navPane

  show: ->
    @navPanel = atom.workspace.addLeftPanel item: @getNavPane()

  hide: ->
    @navPanel.destroy()

  refresh: (reloadFile = false, clearFile = false) ->
    # TODO: This chain is messy
    @navPane.refresh(reloadFile, clearFile) if @navPane

  organizeSummary: ->
    @getNavPane().getParser().organizeFilesFromTree()

  deleteChapter: ->
    atom.confirm
      message: "Are you sure you want to remove this chapter?"
      buttons:
        'Yes': =>
          # This can probably be refactored a bit
          removeFilesOnMenuDelete = atom.config.get('atom-gitbook.removeFilesOnMenuDelete')
          if removeFilesOnMenuDelete == 'Ask'
            atom.confirm
              message: "Would you like to remove the underlying file?"
              buttons:
                'Yes': => @navPane.removeSelectedEntries(true)
                'No' : => @navPane.removeSelectedEntries()

          else if removeFilesOnMenuDelete == 'Yes'
            @navPane.removeSelectedEntries(true)
          else
            @navPane.removeSelectedEntries()
        'No': -> null


  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @navPane.destroy()
    @element.remove()

  getElement: ->
    @element
