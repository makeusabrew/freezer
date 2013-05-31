# builtin/npm deps
http          = require "http"
fs            = require "fs"
child_process = require "child_process"

# local deps
db     = require "./lib/db"
Mode   = require "./lib/mode"
Prompt = require "./lib/prompt"

throw "Please supply a URL to retrieve snapshots for" if process.argv.length isnt 3

url = require("url").parse process.argv[2]
currentMode = Mode.factory "manual"

# boot
Prompt.start()
db.connect ->

    db.collection("sequence").findOne {url: url.href}, (err, sequence) ->
        throw err if err

        throw "Cannot find sequence for URL #{url.href}" if not sequence

        start sequence

start = (sequence) ->
    server = http.createServer onRequest sequence

    bindInput sequence

    currentMode.setSequence sequence

    currentMode.loadSnapshots ->
      server.listen 9999
      Prompt.write "Serving snapshots for sequence #{sequence._id}, URL: #{sequence.url}"


onRequest = (sequence) ->
    (req, res) ->
        res.setHeader "Access-Control-Allow-Origin", "*"

        return res.end "invalid path" if req.url isnt url.path

        snapshot = currentMode.getCurrentSnapshot req

        res.setHeader "Content-Type", "application/json"
        res.end snapshot.raw

        Prompt.write "[web] served snapshot #{snapshot._index}) #{snapshot._date}"

bindInput = (sequence) ->
  Prompt.on "input", (data) ->
    help = "Unrecognised command '#{data}'\n
    - try 'list'"

    # @TODO expose options based on what the currentMode implements
    switch data
      when "n", "next" then currentMode.loadRelative 1
      when "b", "back" then currentMode.loadRelative -1
      when "current"

        snapshot = currentMode.getCurrentSnapshot()

        Prompt.write "Current snapshot: #{snapshot._index}) #{snapshot._date}"

      when "reload"    then currentMode.loadSnapshots -> Prompt.write "Snapshots reloaded"

      when "list"
        currentMode.getSnapshots (snapshots) ->
          for snapshot,i in snapshots
            str = "#{i+1}) #{snapshot._date}"
            str += " [✓]" if i is currentMode.getSnapshotIndex()
            Prompt.write str
      else
        Prompt.write help unless handleArgs data

args = [{
  pattern: /load (\d+)/
  handler: 'load'
}, {
  pattern: /diff (\d+) (\d+)$/
  handler: 'diff'
}, {
  pattern: /diff (\d+) (\d+) full/
  handler: 'fulldiff'
}, {
  pattern: /show (\d+)$/
  handler: 'show'
}]

formatJSON = (data) -> JSON.stringify JSON.parse(data), null, 2

handleArgs = (data) ->
  for arg in args
    matches = data.match arg.pattern
    continue if not matches

    switch arg.handler
      when "load"
        Prompt.write "Loading file #{matches[1]}"
        currentMode.loadAbsolute matches[1]-1

      when "diff", "fulldiff"
        #@TODO DRY up and asyncify
        s1 = currentMode.getSnapshot matches[1]-1
        s2 = currentMode.getSnapshot matches[2]-1

        path1 = "/tmp/snapshot_#{s1._id}"
        path2 = "/tmp/snapshot_#{s2._id}"

        fs.writeFileSync path1, formatJSON s1.raw
        fs.writeFileSync path2, formatJSON s2.raw

        options = if arg.handler is "diff" then "--suppress-common-lines" else "--left-column"

        child_process.exec "diff #{path1} #{path2} -y #{options}", (err, stdout, stderr) ->
          Prompt.write stdout

          fs.unlinkSync path1
          fs.unlinkSync path2

      when "show"
        snapshot = currentMode.getSnapshot matches[1]-1
        Prompt.write formatJSON snapshot.raw

    return true

  return false
