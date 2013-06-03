EventEmitter = require("events").EventEmitter

# @TODO expose some sort of 'loading' mutable property
# where no input is received

prompt      = "=> "
inPrompt    = "<= "
currentLine = ""
emitter     = new EventEmitter

doPrompt = -> process.stdout.write prompt+currentLine

write = (data) -> process.stdout.write data

writeLine = (data, prefix = "") ->
  # clear what we've currently got on the last line
  # [2K = clear line
  # [(n)D = move (n) characters left
  process.stdout.write "\u001B[2K\u001B[100D"

  # add the data for the new line
  process.stdout.write prefix+data+"\n"

  # if we're writing the current line, get rid of it
  currentLine = "" if data is currentLine

  # restore the contents of the current line & prompt
  doPrompt()

  return data


process.stdin.on "data", (char) ->
  switch char
    when "\r"

      emitter.emit 'input', writeLine currentLine, inPrompt

    when "\u0003"
      # CTRL+C
      emitter.emit 'SIGINT'

    when "\u0008", "\x7f"
      # backspace
      # move one char left (1D), delete from cursor to end of line (0K)
      process.stdout.write "\u001B[1D\u001B[0K"

      currentLine = currentLine.substr 0, currentLine.length-1

    else
      currentLine += char
      write char

module.exports =
  start: ->
    # hook up stdin
    process.stdin.resume()
    process.stdin.setEncoding "utf8"
    process.stdin.setRawMode true

    doPrompt()

  write: write

  log: writeLine

  on: (message, callback) -> emitter.on message, callback
