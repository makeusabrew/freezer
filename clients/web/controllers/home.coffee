Controller = require "../../../lib/controller"
Client     = require "../../../lib/client"

#@TODO these methods are really crude and step on each other's toes a bit
#need reworking to be as efficient and neat as possible
getSessions = (callback) ->
  Client.getSessions (err, sessions) =>
    return callback [] if sessions.length is 0
    counts = 0
    for session in sessions
      do (session) =>
        Client.getSequence session.sequenceId, (err, sequence) =>
          counts += 1

          session._sequence = sequence

          callback sessions if counts is sessions.length

getSequences = (sessions, callback) ->
  Client.getSequences (err, sequences) =>
    return callback [] if sequences.length is 0
    counts = 0
    for sequence in sequences
      do (sequence) =>
        Client.countSnapshotsForSequence sequence._id, (err, count) =>
          counts += 1

          sequence._snapshots = count
          sequence._active = isActive sequence, sessions

          callback sequences if counts is sequences.length

isActive = (sequence, sessions) ->
  for session in sessions
    return true if sequence._id.equals(session.sequenceId)
  return false

class HomeController extends Controller
  home: (req, res) ->
    getSessions (sessions) =>
      getSequences sessions, (sequences) =>
        res.send @render "index",
          page: "home"
          sequences: sequences
          sessions: sessions

module.exports = HomeController
