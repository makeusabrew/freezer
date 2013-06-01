EventEmitter = require("events").EventEmitter

prompt      = "=> "
inPrompt    = "<= "
currentLine = ""
emitter     = new EventEmitter

clearLine = ->
    # [2K = clear line
    # [(n)D = move (n) characters left
    process.stdout.write "\u001B[2K\u001B[100D"

doPrompt = -> process.stdout.write prompt+currentLine

writeLine = (data) ->
  # clear what we've currently got on the last line
  clearLine()

  # add the data for the new line
  process.stdout.write data+"\n"

  # restore the contents of the current line & prompt
  doPrompt()

process.stdin.on "data", (char) ->
  if char is "\r"
    # carriage return - check input

    # store the current line...
    data = currentLine
    # ... wipe it
    currentLine = ""

    # write the new line to the prompt (this will restore 'currentLine' afterwards)
    writeLine inPrompt+data

    emitter.emit 'input', data

  else if char is "\u0003"
    # CTRL+C
    emitter.emit 'SIGINT'
  else if char is "\u0008" or char is "\x7f"
    # backspace
    # move one char left (1D), delete from cursor to end of line (0K)
    process.stdout.write "\u001B[1D\u001B[0K"

    currentLine = currentLine.substr 0, currentLine.length-1
  else
    process.stdout.write char
    currentLine += char

module.exports =
  start: ->
    # hook up stdin
    process.stdin.resume()
    process.stdin.setEncoding "utf8"
    process.stdin.setRawMode true

    doPrompt()

  write: writeLine

  on: (message, callback) -> emitter.on message, callback
