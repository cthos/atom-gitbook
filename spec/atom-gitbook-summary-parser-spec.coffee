SummaryParser = require '../lib/helper/summary-parser'

describe 'SummaryParser', ->

  [parserInstance] = []

  beforeEach ->
    parserInstance = new SummaryParser('test')

  describe "Converting markdown lists to a tree.", ->
    it "should handle a single item", ->
      item = "* [Valid Markdown](readme.md)"

      parserInstance.parseFileToTree(item)
      tree = parserInstance.tree

      expect(tree.length).toBe 1
      expect(tree[0].indent).toBe 0
      expect(tree[0].name).toBe "Valid Markdown"
      expect(tree[0].file).toBe "readme.md"

    it "should handle multiple items on the same indent level", ->
      items = """
      * [Valid Markdown](readme.md)
      * [More Valid Markdown](otherfile.md)
      """
      parserInstance.parseFileToTree(items)
      tree = parserInstance.tree

      expect(tree.length).toBe 2
      expect(tree[1].indent).toBe 0
      expect(tree[1].name).toBe "More Valid Markdown"
      expect(tree[1].file).toBe "otherfile.md"

    it "shoud handle multiple items of different indentation levels", ->
      items = """
      * [Valid Markdown](readme.md)
        * [Indented Item](indent.md)
      * [More Valid Markdown](otherfile.md)
      """
      parserInstance.parseFileToTree(items)
      tree = parserInstance.tree

      expect(tree.length).toBe 3
      expect(tree[1].indent).toBe 2
      expect(tree[0].indent).toBe 0
      expect(tree[2].indent).toBe 0
      expect(tree[1].name).toBe "Indented Item"

    it "should handle numerically indexed summary files.", ->
      items = """
      1. [Valid Markdown](readme.md)
      2. [Second Item](indent.md)
      1. [More Valid Markdown](otherfile.md)
      """
      parserInstance.parseFileToTree(items)
      tree = parserInstance.tree

      expect(tree.length).toBe 3
      expect(tree[1].name).toBe "Second Item"
