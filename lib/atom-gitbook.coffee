{CompositeDisposable} = require 'atom'

module.exports =
class AtomGitbook

  activate: (state) ->
    @atomGitbookView = new AtomGitbookView(state.atomGitbookViewState)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-gitbook:toggle': => @toggle()

  deactivate: ->
    @subscriptions.dispose()
    @atomGitbookView.destroy()

  serialize: ->
    atomGitbookViewState: @atomGitbookView.serialize()

  toggle: ->
    if @open
      @atomGitbookView.hide()
      @open = false
    else
      @atomGitbookView.show()
      @open = true
