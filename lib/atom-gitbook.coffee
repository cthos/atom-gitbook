{CompositeDisposable} = require 'atom'
fs = require 'fs-plus'
path = require 'path'

module.exports =
class AtomGitbook

  openEditorFile: (filename) ->
    curPath = atom.project.getPaths()[0]

    filepath = path.join(curPath, filename)

    if fs.existsSync(filepath)
      atom.workspace.open(filepath)
