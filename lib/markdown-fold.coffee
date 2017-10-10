{CompositeDisposable} = require 'atom'

module.exports = MarkdownFold =
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that folds this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'markdown-fold:fold': => @fold()

  deactivate: ->
    @subscriptions.dispose()

  # serialize: ->

  fold: ->
    # fail returns FALSE
    return false unless _editor = atom.workspace.getActiveTextEditor()
    _buffer = _editor.buffer
    # _checkpoint = _editor.createCheckpoint()  # does not work!
    _search = /^# /g  # This would change according to what marks a heading
    _lineNr = [] # empty array saves row numbers

    console.log 'started: test command'

    # GET ROWS WHERE SEARCH TERM CAN BE REACHED
    _buffer.scan _search, (_grab) ->
      # ..this does a buffer wide search,
      # but a limited search can be used instead
      # using scanInRange()
      _lineNr.push _grab.range.start.row

    _lineNr.push _buffer.getLastRow()  # assume until last row in buffer
    _isFirst = true  # handling first iteration as special case
    P1 = []

    # ITERATE THROUGH ROW LINE LIST
    for x in _lineNr
      if not _isFirst
        # `clip` ensures legal position point
        P2 = _buffer.clipPosition([x-1, 1000])
        console.log [P1,P2]  # ..for testing
        _editor.setSelectedBufferRange([P1,P2])  # MAKE SELECTION FOR FOLDING
        _editor.foldSelectedLines()  # INVOKE FOLDING
      P1 = _buffer.clipPosition([x, 1000])
      _isFirst = false

    # _editor.groupChangesSinceCheckpoint(_checkpoint) # does not work!
    return true  # feedback TRUE
