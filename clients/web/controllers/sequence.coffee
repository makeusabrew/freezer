Controller = require "../lib/controller"
db         = require "../lib/db"
Utils      = require "../lib/utils"

findSequenceAndSnapshots = (id, callback) ->
    db.findById "sequence", id, (err, doc) ->
        throw err if err

        db.collection("snapshot").find(sequenceId: doc._id).toArray (err, docs) ->
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
        db.findById "snapshot", req.params.snapshotId, (err, doc) =>
            res.send @render "snapshot",
                page: "snapshot"
                snapshot: doc
                formatted: Utils.formatJSON doc.raw

module.exports = SequenceController
