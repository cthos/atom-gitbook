Parser = require './helper/summary-parser'
AtomGitbook = require './atom-gitbook'
fs = require 'fs-plus'
{$, View} = require 'atom-space-pen-views'

module.exports =
class NavigationPane extends View
  @content: ->
    @div class: 'gitbook-navigation-pane', =>
      @div class: 'gitbook-navigation-pane-label', =>
        @h2 "Table of Contents"
      @div class: 'gitbook-navigation-container tool-panel', outlet: 'tree'

  initialize: ->
    @elementCache = {}
    @AtomGitbook = new AtomGitbook

    @parser = Parser.getInstance(atom.project.getPaths()[0])
    @refreshTree()
    @initEvents()

  initEvents: ->
    @on 'dblclick', '.gitbook-page-item', (e) =>
      ## Open File in Editor window if exists.
      if e.currentTarget.dataset.filename?
        @AtomGitbook.openEditorFile(e.currentTarget.dataset.filename, e.currentTarget.innerHTML)
    @on 'click', '.gitbook-page-item', (e) =>
      @deselectMenuItems() unless e.shiftKey or e.metaKey or e.ctrlKey
      @selectElement(e.target)
    @on 'mousedown', '.gitbook-page-item', (e) =>
      # Select the element if we're right clicking.
      if e.button is 2
        @deselectMenuItems()
        @selectElement(e.target)

  selectElement: (ele) ->
    ele.classList.add('chapter-selected')

  deselectMenuItems: ->
    # Technique borrowed from tree view
    elements = @root.querySelectorAll('.chapter-selected')

    for element in elements
      element.classList.remove('chapter-selected')

  removeSelectedEntries: ->
    elements = @root.querySelectorAll('.chapter-selected')

    return unless elements?

    for ele in elements
      @parser.deleteSection(ele.dataset.filename)

    @parser.generateFileFromTree(atom.project.getPaths()[0])
    @refreshTree()

  refreshTree: ->
    @tree[0].removeChild(@tree[0].firstChild) while @tree[0].firstChild
    @elementCache = []

    @root = document.createElement('ul')
    @root.classList.add('full-menu');
    @root.classList.add('list-tree');
    @root.classList.add('has-collapsable-children');
    @elementCache[0] = [@root]

    for item in @parser.tree
      @genDepthElement(item)

    @tree.append(@root)

  genDepthElement: (treeEl) ->
    treeEl.indent = 0 unless treeEl.indent

    @elementCache[treeEl.indent] = [] unless @elementCache[treeEl.indent]?
    parentEl = @root

    if treeEl.indent > 0
      parentIndent = treeEl.indent - 2;
      parentIndent = 0 if parentIndent < 0

      rootEl = @elementCache[parentIndent][@elementCache[parentIndent].length - 1]

      parentEl = document.createElement('ul')
      rootEl.appendChild(parentEl)

      @elementCache[treeEl.indent].push(parentEl)

    childEl = document.createElement('li')
    childEl.classList.add('gitbook-page-item')
    childEl.classList.add('icon-file-text')
    childEl.dataset.filename = treeEl.file
    childEl.innerHTML = treeEl.name

    parentEl.appendChild(childEl)
