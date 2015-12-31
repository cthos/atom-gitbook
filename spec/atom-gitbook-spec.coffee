AtomGitbook = require '../lib/atom-gitbook'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "AtomGitbook", ->
  [workspaceElement, activationPromise, findNavPanel] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('atom-gitbook')

    findNavPanel = ->
      panels = atom.workspace.getLeftPanels()
      navPanel = null
      panels.forEach (panel) ->
        ## Feels like a hack....
        navPanel = panel.getItem() if panel.item.constructor.name == 'NavigationPane'
      navPanel

  describe "when the atom-gitbook:toggle event is triggered", ->
    it "hides and shows the modal panel", ->
      expect(workspaceElement.querySelector('.gitbook-navigation-pane')).not.toExist()

      waitsForPromise ->
        activationPromise

      runs ->
        jasmine.attachToDOM(workspaceElement)
        atom.commands.dispatch workspaceElement, 'atom-gitbook:toggle'
        panel = findNavPanel()

        expect(panel).toExist()

        expect(panel.isVisible()).toBe true
        atom.commands.dispatch workspaceElement, 'atom-gitbook:toggle'
        expect(panel.isVisible()).toBe false
