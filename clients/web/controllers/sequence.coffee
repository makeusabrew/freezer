Controller = require "../../../lib/controller"
Client     = require "../../../lib/client"
Utils      = require "../../../lib/utils"

findSequenceAndSnapshots = (id, callback) ->
  Client.getSequence id, (err, doc) ->
    throw err if err

    return callback null, null if not doc

    Client.getSnapshotsForSequence doc._id.toString(), (err, docs) ->
      throw err if err

      callback doc, docs

class SequenceController extends Controller
  view: (req, res) ->
    findSequenceAndSnapshots req.params.id, (sequence, snapshots) =>
      res.send @render "sequence",
        page: "sequence"
        sequence: sequence
        snapshots: snapshots

  viewSnapshot: (req, res) ->
    Client.getSnapshot req.params.snapshotId, (err, doc) =>
      res.send @render "snapshot",
        page: "snapshot"
        snapshot: doc
        formatted: Utils.formatJSON doc.raw

module.exports = SequenceController
