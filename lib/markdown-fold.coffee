{CompositeDisposable} = require 'atom'

module.exports = MarkdownFold =
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that folds this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'markdown-fold:fold': => @fold()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()

  serialize: ->

  fold: ->
    console.log 'Markdown was folded!'
