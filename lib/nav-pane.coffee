Parser = require './helper/summary-parser'
AtomGitbook = require './atom-gitbook'
fs = require 'fs-plus'
{$, View} = require 'atom-space-pen-views'

module.exports =
class NavigationPane extends View
  @content: ->
    @div class: 'gitbook-navigation-pane', =>
      @div class: 'gitbook-navigation-title', outlet: 'tree', "This is the rendered bar"

  initialize: ->
    @elementCache = {}
    @AtomGitbook = new AtomGitbook

    project = atom.project.getPaths()
    parseTime = new Parser project[0]
    currentIndent = 0

    @root = document.createElement('ul')
    @elementCache[0] = [@root]

    for item in parseTime.tree
      @genDepthElement(item)

    @tree.append(@root)

    @initEvents()

  initEvents: ->
    @on 'dblclick', '.gitbook-page-item', (e) =>
      ## Open File in Editor window if exists.
      console.log e.currentTarget.dataset.filename
      @AtomGitbook.openEditorFile(e.currentTarget.dataset.filename) if e.currentTarget.dataset.filename?

  genDepthElement: (treeEl) ->
    treeEl.indent = 0 unless treeEl.indent

    @elementCache[treeEl.indent] = [] unless @elementCache[treeEl.indent]?
    parentEl = @root

    if treeEl.indent > 0
      parentIndent = treeEl.indent - 2;
      parentIndent = 0 if parentIndent < 0

      console.log treeEl

      rootEl = @elementCache[parentIndent][@elementCache[parentIndent].length - 1]

      parentEl = document.createElement('ul')
      rootEl.appendChild(parentEl)

      @elementCache[treeEl.indent].push(parentEl)

    childEl = document.createElement('li')
    childEl.classList.add('gitbook-page-item')
    # TODO Data attr for linked filename
    childEl.dataset.filename = treeEl.file
    childEl.innerHTML = treeEl.name

    parentEl.appendChild(childEl)
