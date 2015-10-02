{$, TextEditorView, View} = require 'atom-space-pen-views'

module.exports =
class NewChapterView extends View
  @content: ->
    @div class: 'new-chapter-modal', =>
      @label 'Please enter the new Chapter Name'
      @subview 'miniEditor', new TextEditorView(mini: true)

  initialize: ->
    atom.commands.add @element,
      # Core confirm is emitted on "enter" for the mini TextEditorView
      'core:confirm': => @onConfirm(@miniEditor.getText())
      'core:cancel': => @cancel()
    @miniEditor.on 'blur', => @close()

  attach: ->
    @panel = atom.workspace.addModalPanel(item: this)
    @miniEditor.focus()
    @miniEditor.getModel().scrollToCursorPosition()

  onConfirm: ->
    console.log "Submitted!"
    console.log @miniEditor.getText()

  close: ->
    @panel.destroy()
