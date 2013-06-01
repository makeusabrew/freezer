fs            = require "fs"
child_process = require "child_process"
urlParse      = require("url").parse

# local deps
Mode    = require "./lib/mode"
Prompt  = require "./lib/prompt"
Utils   = require "./lib/utils"
Freezer = require "./lib/freezer"

throw "Please supply a URL to retrieve snapshots for" if process.argv.length isnt 3

url = urlParse process.argv[2]
currentMode = Mode.factory "manual"

Prompt.start()

Freezer.start ->

  options =
    url: url.href
    path: url.path  # can be set to whatever we like per session
    mode: "manual"

  Freezer.startSession options, (err, session, sequence) ->
    throw err if err

    console.log "registered new session #{session._id}"

    start session.sequence

start = (sequence) ->

  Prompt.on "input", onInput

  currentMode.setSequence sequence

  currentMode.loadSnapshots ->
    Prompt.write "Serving snapshots for sequence #{sequence._id}, URL: #{sequence.url}"

onInput = (data) ->
    help = "Unrecognised command '#{data}'\n - try 'list', '(n)ext', '(b)ack', 'current', 'reload', 'list', 'load [n]', 'diff [n] [m]'"

    # @TODO expose options based on what the currentMode implements
    switch data
        when "n", "next", "b", "back"
            offset = if data is "n" or data is "next" then 1 else -1
            currentMode.loadRelative offset

            displayCurrent()

        when "current" then displayCurrent()

        when "reload"  then currentMode.loadSnapshots -> Prompt.write "Snapshots reloaded"

        when "list"    then currentMode.getSnapshots displayAll

        else           Prompt.write help unless handleArgs data

displayCurrent = -> displaySnapshot currentMode.getCurrentSnapshot()

displaySnapshot = (snapshot) -> Prompt.write "Current snapshot: #{snapshot._index}) #{snapshot._date} (#{snapshot._id})"

displayAll = (snapshots) ->
    for snapshot,i in snapshots
        str = "#{snapshot._index}) #{snapshot._date}"
        str += " [✓]" if i is currentMode.getSnapshotIndex()
        Prompt.write str

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

handleArgs = (data) ->
  for arg in args
    matches = data.match arg.pattern
    continue if not matches

    switch arg.handler
      when "load"
        Prompt.write "Loading file #{matches[1]}"
        currentMode.loadAbsolute matches[1]-1

      when "diff", "fulldiff"
        #@TODO tidy up; this is a bit of a mess
        s1 = currentMode.getSnapshot matches[1]-1
        s2 = currentMode.getSnapshot matches[2]-1

        options = if arg.handler is "diff" then "--suppress-common-lines" else "--left-column"
        path = "/tmp/snapshot_"
        files = 0

        for snapshot in [s1, s2]
            do (snapshot) ->

                fs.writeFile path+snapshot._id, Utils.formatJSON(snapshot.raw), (err) ->
                    throw err if err

                    files += 1

                    return if files < 2

                    child_process.exec "diff #{path+s1._id} #{path+s2._id} -y #{options}", (err, stdout, stderr) ->
                        Prompt.write stdout

                        fs.unlink path+s1._id, (err) ->
                        fs.unlink path+s2._id, (err) ->

      when "show"
        snapshot = currentMode.getSnapshot matches[1]-1
        Prompt.write Utils.formatJSON snapshot.raw

    return true

  return false
