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

  refresh: (reloadFile = false) ->
    @navPane.refresh(reloadFile) if @navPane

  deleteChapter: ->
    atom.confirm
      message: "Are you sure you want to remove this chapter?"
      buttons:
        'Yes': =>
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
