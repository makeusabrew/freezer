Controller = require "../../../lib/controller"
Freezer    = require "../../../lib/client"
Utils      = require "../../../lib/utils"

_id = (id) -> Freezer.toObjectId id

findSequenceAndSnapshots = (id, callback) ->
  Freezer.getSequence _id(id), (err, doc) ->
    throw err if err

    Freezer.getSnapshotsForSequence doc._id, (err, docs) ->
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
    Freezer.getSnapshot _id(req.params.snapshotId), (err, doc) =>
      res.send @render "snapshot",
        page: "snapshot"
        snapshot: doc
        formatted: Utils.formatJSON doc.raw

module.exports = SequenceController
