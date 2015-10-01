Parser = require './helper/summary-parser'
fs = require 'fs-plus'
{$, View} = require 'atom-space-pen-views'

module.exports =
class NavigationPane extends View
  @content: ->
    @div class: 'gitbook-navigation-pane', =>
      @div class: 'gitbook-navigation-title', "This is the rendered bar"
      @ul outlet: 'tree', class: "gitbook-pages-list"

  initialize: ->
    project = atom.project.getPaths()
    parseTime = new Parser project[0]

    for item in parseTime.tree
      @tree.append("<li class='gitbook-page-item'>#{item.name}</li>")
