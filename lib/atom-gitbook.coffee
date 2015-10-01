AtomGitbookView = require './atom-gitbook-view'
{CompositeDisposable} = require 'atom'

module.exports = AtomGitbook =
  atomGitbookView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @atomGitbookView = new AtomGitbookView(state.atomGitbookViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @atomGitbookView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-gitbook:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @atomGitbookView.destroy()

  serialize: ->
    atomGitbookViewState: @atomGitbookView.serialize()

  toggle: ->
    console.log 'AtomGitbook was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
