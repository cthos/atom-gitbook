{CompositeDisposable} = require 'atom'
fs = require 'fs-plus'
path = require 'path'

module.exports =
class AtomGitbook

  openEditorFile: (filename, name) ->
    curPath = atom.project.getPaths()[0]

    filepath = path.join(curPath, filename)

    if fs.existsSync(filepath)
      atom.workspace.open(filepath)
    else
      atom.confirm
        message: "Underlying File does not exist. Create it?"
        buttons:
          'Okay': =>
            # TODO Async?
            fs.writeFileSync(filepath, '# ' + name)
            atom.workspace.open(filepath)
          'Cancel': -> null
