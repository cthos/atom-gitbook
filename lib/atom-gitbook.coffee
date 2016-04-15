{CompositeDisposable} = require 'atom'
fs = require 'fs-plus'
path = require 'path'

module.exports =
class AtomGitbook

  openEditorFile: (filename, name) ->
    curPath = atom.project.getPaths()[0]

    filepath = path.join(curPath, filename)

    if fs.existsSync(filepath)
      atom.workspace.open(filepath).then =>
        # TODO: Helper Class?
        editorElement = atom.views.getView(atom.workspace.getActiveTextEditor())
        if atom.config.get('atom-gitbook.autoOpenMarkdownPreview')
          atom.commands.dispatch(editorElement, 'markdown-preview:toggle')
    else
      atom.confirm
        message: "Underlying File does not exist. Create it?"
        buttons:
          'Okay': =>
            # TODO Async?
            fs.writeFileSync(filepath, '# ' + name)
            atom.workspace.open(filepath).then =>
              editorElement = atom.views.getView(atom.workspace.getActiveTextEditor())
              atom.commands.dispatch(editorElement, 'markdown-preview:toggle')
          'Cancel': -> null
