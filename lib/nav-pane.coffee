Parser = require './helper/summary-parser'
AtomGitbook = require './atom-gitbook'
fs = require 'fs-plus'
path = require 'path'
{$, View} = require 'atom-space-pen-views'

module.exports =
class NavigationPane extends View
  @content: ->
    @div class: 'gitbook-navigation-pane', =>
      @div class: 'gitbook-navigation-pane-label', =>
        @h2 "Table of Contents"
      @div class: 'gitbook-navigation-container tool-panel', tabindex: -1, outlet: 'tree'

  initialize: ->
    @elementCache = {}
    @AtomGitbook = new AtomGitbook
    @getParser()
    @initEvents()

  getParser: ->
    if not @parser?
      @parser = Parser.getInstance(atom.project.getPaths()[0])
      @parser.reload()
    @parser

  refresh: (reloadFile = false, clearFile = false) ->
    @getParser().reload(clearFile) if reloadFile
    @refreshTree()

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
    @on 'dragstart', '.gitbook-page-item', (e) =>
      @draggedElement = e.target;
      e.stopPropagation()

    @on 'dragenter', '.gitbook-page-item, .gitbook-seperator', (e) =>
      e.stopPropagation()
      @clearHovers()

      e.target.classList.add('gitbook-hover-target')

    @on 'dragleave', '.gitbook-page-item, .gitbook-seperator', (e) =>
      e.preventDefault()
      e.stopPropagation()

    @on 'dragover', '.gitbook-page-item, .gitbook-seperator', (e) =>
      e.preventDefault()
      e.stopPropagation()

    @on 'drop', '.gitbook-page-item, .gitbook-seperator', (e) =>
      if @draggedElement
        elFile = e.target.dataset.filename if e.target.dataset.filename?
        index = e.target.dataset.index if e.target.dataset.index?

        ds = @draggedElement.dataset

        # TODO: This needs to handle when an element has children
        @getParser().deleteSection(ds.filename)
        @getParser().addSection(@draggedElement.innerHTML, ds.filename, elFile, index)
        @getParser().generateFileFromTree()
        @refresh()

        @draggedElement = null

  clearHovers: ->
    hoverTargets = document.querySelectorAll('.gitbook-hover-target')
    for h in hoverTargets
      h.classList.remove('gitbook-hover-target')

  selectElement: (ele) ->
    ele.classList.add('chapter-selected')

  deselectMenuItems: ->
    # Technique borrowed from tree view
    elements = @root.querySelectorAll('.chapter-selected')

    for element in elements
      element.classList.remove('chapter-selected')

  removeSelectedEntries: (deleteUnderlyingFiles = false) ->
    elements = @root.querySelectorAll('.chapter-selected')

    return unless elements?

    for ele in elements
      @parser.deleteSection(ele.dataset.filename)
      if deleteUnderlyingFiles
        fullPath = path.join(atom.project.getPaths()[0], ele.dataset.filename);
        fs.unlinkSync(fullPath)

    @getParser().generateFileFromTree()
    @refreshTree()

  refreshTree: ->
    @tree[0].removeChild(@tree[0].firstChild) while @tree[0].firstChild
    @elementCache = []

    @root = document.createElement('ul')
    @root.classList.add('full-menu');
    @root.classList.add('list-tree');
    @root.classList.add('has-collapsable-children');
    @elementCache[0] = [@root]

    for item, index in @parser.tree
      @genDepthElement(item, index)

    @tree.append(@root)

  genDepthElement: (treeEl, index) ->
    treeEl.indent = 0 unless treeEl.indent

    @elementCache[treeEl.indent] = [] unless @elementCache[treeEl.indent]?
    parentEl = @root

    if treeEl.indent > 0
      until parentIndent? and @elementCache[parentIndent]?
        if not parentIndent?
          parentIndent = treeEl.indent - 2;
        else
          parentIndent -= 2

      rootEl = @elementCache[parentIndent][@elementCache[parentIndent].length - 1]

      parentEl = document.createElement('ul')
      rootEl.appendChild(parentEl)

      @elementCache[treeEl.indent].push(parentEl)

    childEl = document.createElement('li')
    childEl.classList.add('gitbook-page-item')
    childEl.classList.add('icon-file-text')
    childEl.dataset.filename = treeEl.file
    childEl.setAttribute('draggable', true)

    childEl.innerHTML = treeEl.name

    parentEl.appendChild(childEl)

    belowEl = document.createElement('div')
    belowEl.classList.add('gitbook-seperator')
    belowEl.dataset.index = index + 1

    parentEl.appendChild(belowEl)
