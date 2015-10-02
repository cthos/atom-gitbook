NavPane = require './nav-pane'
fs = require 'fs-plus'
path = require 'path'

module.exports =
class AtomGitbookView
  constructor: (serializedState) ->

  show: ->
    @navPane = new NavPane
    @navPanel = atom.workspace.addLeftPanel item: @navPane

  hide: ->
    @navPanel.destroy()
    @navPane = null

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
