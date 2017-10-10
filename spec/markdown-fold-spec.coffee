MarkdownFold = require '../lib/markdown-fold'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "MarkdownFold", ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('markdown-fold')

  describe "when the markdown-fold:fold event is triggered", ->
    it "hides and shows the modal panel", ->
      # Before the activation event the view is not on the DOM, and no panel
      # has been created
      expect(workspaceElement.querySelector('.markdown-fold')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.commands.dispatch workspaceElement, 'markdown-fold:fold'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(workspaceElement.querySelector('.markdown-fold')).toExist()

        markdownFoldElement = workspaceElement.querySelector('.markdown-fold')
        expect(markdownFoldElement).toExist()

        markdownFoldPanel = atom.workspace.panelForItem(markdownFoldElement)
        expect(markdownFoldPanel.isVisible()).toBe true
        atom.commands.dispatch workspaceElement, 'markdown-fold:fold'
        expect(markdownFoldPanel.isVisible()).toBe false

    it "hides and shows the view", ->
      # This test shows you an integration test testing at the view level.

      # Attaching the workspaceElement to the DOM is required to allow the
      # `toBeVisible()` matchers to work. Anything testing visibility or focus
      # requires that the workspaceElement is on the DOM. Tests that attach the
      # workspaceElement to the DOM are generally slower than those off DOM.
      jasmine.attachToDOM(workspaceElement)

      expect(workspaceElement.querySelector('.markdown-fold')).not.toExist()

      # This is an activation event, triggering it causes the package to be
      # activated.
      atom.commands.dispatch workspaceElement, 'markdown-fold:fold'

      waitsForPromise ->
        activationPromise

      runs ->
        # Now we can test for view visibility
        markdownFoldElement = workspaceElement.querySelector('.markdown-fold')
        expect(markdownFoldElement).toBeVisible()
        atom.commands.dispatch workspaceElement, 'markdown-fold:fold'
        expect(markdownFoldElement).not.toBeVisible()
