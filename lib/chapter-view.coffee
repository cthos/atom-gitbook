{$, TextEditorView, View} = require 'atom-space-pen-views'
{Emitter} = require 'atom'
slug = require 'slug'
fs = require 'fs-plus'
path = require 'path'

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
      # Cancel is escape
      'core:cancel': => @cancel()
    @miniEditor.on 'blur', => @close()

  attach: ->
    @panel = atom.workspace.addModalPanel(item: this)
    @miniEditor.focus()
    @miniEditor.getModel().scrollToCursorPosition()

  onConfirm: ->
    # TODO: Handle sub-chapters
    txt = @miniEditor.getText()
    filename = slug(txt, {replacement: "_", lower: true}) + '.md'

    wsPath = atom.project.getPaths()[0]
    fullpath = path.join(wsPath, filename)

    if not fs.existsSync(fullpath)
      ## TODO: Async?
      fs.writeFileSync(fullpath, '# ' + txt)

    atom.workspace.open(fullpath)
    @close()

  cancel: ->
    @close()

  close: ->
    depPanel = @panel
    @panel = null
    depPanel?.destroy()
