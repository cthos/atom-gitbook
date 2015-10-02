NavPane = require './nav-pane'
fs = require 'fs-plus'
path = require 'path'

module.exports =
class AtomGitbookView
  constructor: (serializedState) ->

  show: ->
    @navPanel = atom.workspace.addLeftPanel item: new NavPane

  hide: ->
    @navPanel.destroy()

  deleteEntry: ->

    

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @navPane.destroy()
    @element.remove()

  getElement: ->
    @element
