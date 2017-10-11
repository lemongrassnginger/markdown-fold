{CompositeDisposable} = require 'atom'

module.exports = MarkdownFold =
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that folds this view
    # fold
    @subscriptions.add atom.commands.add 'atom-workspace', 'markdown-fold:fold-all': => @foldAll()
    # fold-h1
    @subscriptions.add atom.commands.add 'atom-workspace', 'markdown-fold:fold-h1': => @foldH1()

  deactivate: ->
    @subscriptions.dispose()

  # serialize: ->

  # Fold all sections in active editor separated by H1 headers
  foldAll: ->
    # Fold all sections separated by header lines (lines starting with one or more #)
    @foldByHeader(/^=+ /g)

  # fold all sections in active editor separated by any level of header
  foldH1: ->
    # fold all sections separated by H1 header lines (lines starting with a single #)
    @foldByHeader(/^= /g)

  # Fold sections in active editor that are separated by lines matching xHeaderPattern
  # xHeaderPattern: regex pattern defining a section heading line, eg /^# /g
  foldByHeader: (xHeaderPattern) ->
    # fail returns FALSE
    return false unless oEditor = atom.workspace.getActiveTextEditor()
    oBuffer = oEditor.buffer

    # row numbers of the start of each buffer line that matches the pattern
    aLines = @getHeaderRowNumbers(oBuffer, xHeaderPattern)

    # include last line to close the last section in the buffer
    aLines.push oBuffer.getLastRow()

    # Fold rows between header rows
    @foldSections(oEditor, aLines)

    # feedback TRUE
    return true

  # return array of line numbers for lines in oBuffer that match xHeaderPattern
  getHeaderRowNumbers: (oBuffer, xHeaderPattern) ->
    aLines = []
    # scan buffer for rows matching the section header pattern
    # this does a buffer wide search, but a limited search
    #     can be used instead using scanInRange()
    #     PONDER: could we use this approach to fold/unfold a single section at a time?
    oBuffer.scan xHeaderPattern, (oGrab) ->
      # oGrab represents a header line, save the row number
      aLines.push oGrab.range.start.row
    # return array of header line numbers
    return aLines

  # fold sections in oEditor, between the lines specified in aLines
  foldSections: (oEditor, aLines) ->
    oBuffer = oEditor.buffer
    # handling first iteration as special case
    bIsFirst = true
    # 'Point': coordinates of a position in a buffer used for defining a selection
    Point1 = []
    # fold each section
    for x in aLines
      if not bIsFirst
        # Point for the last line of the previous section
        # `clip` ensures legal position point
        Point2 = oBuffer.clipPosition([x-1, 1000])
        # console.log [P1,P2]  # ..for testing
        # fold the range by selecting it
        oEditor.setSelectedBufferRange([Point1,Point2])
        # fold selection
        oEditor.foldSelectedLines()
      # get the start of the next section
      Point1 = oBuffer.clipPosition([x, 1000])
      bIsFirst = false
