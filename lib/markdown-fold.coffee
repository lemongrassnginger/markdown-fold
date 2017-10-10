{CompositeDisposable} = require 'atom'

module.exports = MarkdownFold =
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that folds this view
    # fold
    @subscriptions.add atom.commands.add 'atom-workspace', 'markdown-fold:fold-all': => @fold(/^#+ /g)
    # fold-h1
    @subscriptions.add atom.commands.add 'atom-workspace', 'markdown-fold:fold-h1': => @fold(/^# /g)

  deactivate: ->
    @subscriptions.dispose()

  # serialize: ->

  # Fold sections lines in active editor
  # Sections are defined as starting with any line matching headerPattern
  #   and finishing on the line before the next section (or the end of the file)
  #
  # headerPattern: regex pattern defining a section heading line, eg /^# /g
  fold: (headerPattern) ->
    # fail returns FALSE
    return false unless _editor = atom.workspace.getActiveTextEditor()
    _buffer = _editor.buffer
    # row numbers of the start of each section matched
    _lineNr = []

    # console.log 'Start: markdown-fold:fold'  # ..for testing

    # scan buffer for rows matching the section header pattern
    # this does a buffer wide search, but a limited search
    #     can be used instead using scanInRange()
    _buffer.scan headerPattern, (_grab) ->
      # _grab represents a header line, save the row number
      _lineNr.push _grab.range.start.row

    # include last line to close the last section
    _lineNr.push _buffer.getLastRow()
    # handling first iteration as special case
    _isFirst = true
    # 'Point': coordinates of a position in a buffer used for defining a selection
    Point1 = []

    # fold each section
    for x in _lineNr
      if not _isFirst
        # Point for the last line of the previous section
        # `clip` ensures legal position point
        Point2 = _buffer.clipPosition([x-1, 1000])
        # console.log [P1,P2]  # ..for testing
        # fold the range by selecting it
        _editor.setSelectedBufferRange([Point1,Point2])
        # fold selection
        _editor.foldSelectedLines()
      # get the start of the next section
      Point1 = _buffer.clipPosition([x, 1000])
      _isFirst = false

    # feedback TRUE
    return true
