fs            = require "fs"
child_process = require "child_process"
urlParse      = require("url").parse

# local deps
#@TODO review the concept of 'Modes'... it's something thus far only
#this app cares about, and it only implements 'manual' anyway...
Mode    = require "./lib/mode"

# app deps
Prompt  = require "../lib/prompt"
Utils   = require "../lib/utils"
Client  = require "../lib/client"

throw "Please supply a URL to retrieve snapshots for" if process.argv.length < 3

url         = urlParse process.argv[2]
path        = process.argv[3] || url.path
currentMode = Mode.factory "manual"

start = ->
  # @TODO we should accept either a URL or a sequence ID here based on what the input looks like
  options =
    url: url.href
    path: path

  Client.createSession options, (err, session) ->
    throw err if err

    Prompt.log "registered new session #{session._id}"

    currentMode.setSession session

    currentMode.loadSnapshots ->
      Prompt.log "Managing snapshots for sequence: #{session.sequence._id}\nURL: #{session.sequence.url}"
      # @TODO host below needs to come from config or be discovered... or something
      Prompt.log "Snapshot server responding to requests on http://localhost:9999#{session.path}"

      currentMode.loadAbsolute 0, (err) ->
        throw err if err

    Prompt.on "SIGINT", ->
      Prompt.log "Closing session..."
      Client.deleteSession session._id, (err) ->
        throw err if err

        Prompt.log "session terminated, exiting"
        process.exit 0

Prompt.on "input", (data) ->
    help = "Unrecognised command '#{data}'\n - try 'list', '(n)ext', '(b)ack', 'current', 'reload', 'list', 'load [n]', 'diff [n] [m]'"

    # @TODO expose options based on what the currentMode implements
    switch data
        when "n", "next", "b", "back"
            offset = if data is "n" or data is "next" then 1 else -1
            currentMode.loadRelative offset, -> displayCurrent()

        when "current" then displayCurrent()

        when "reload"  then currentMode.loadSnapshots -> Prompt.log "Snapshots reloaded"

        when "list"    then currentMode.getSnapshots displayAll

        else           Prompt.log help unless handleArgs data

displayCurrent = -> displaySnapshot currentMode.getCurrentSnapshot()

displaySnapshot = (snapshot) -> Prompt.log "Current snapshot: #{snapshot._index}) #{snapshot._date} (#{snapshot._id})"

displayAll = (snapshots) ->
    for snapshot,i in snapshots
        str = "#{snapshot._index}) #{snapshot._date}"
        str += " [✓]" if i is currentMode.getSnapshotIndex()
        Prompt.log str

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
        Prompt.log "Loading file #{matches[1]}"
        currentMode.loadAbsolute matches[1]-1, (err) ->
          Prompt.log if err then err else "OK"

      when "diff", "fulldiff"
        #@TODO tidy up; this is a bit of a mess
        s1 = currentMode.getSnapshot matches[1]-1
        s2 = currentMode.getSnapshot matches[2]-1

        options = if arg.handler is "diff" then "--suppress-common-lines" else "--left-column"
        path = "/tmp/snapshot_"
        files = 0

        for snapshot in [s1, s2]
            do (snapshot) ->

                fs.logFile path+snapshot._id, Utils.formatJSON(snapshot.raw), (err) ->
                    throw err if err

                    files += 1

                    return if files < 2

                    child_process.exec "diff #{path+s1._id} #{path+s2._id} -y #{options}", (err, stdout, stderr) ->
                        Prompt.log stdout

                        fs.unlink path+s1._id, (err) ->
                        fs.unlink path+s2._id, (err) ->

      when "show"
        snapshot = currentMode.getSnapshot matches[1]-1
        Prompt.log Utils.formatJSON snapshot.raw

    return true

  return false

Prompt.start()
start()
