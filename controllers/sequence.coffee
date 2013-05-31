Controller = require "../lib/controller"
db         = require "../lib/db"

class SequenceController extends Controller
    view: (req, res) ->
        db.findById "sequence", req.params.id, (err, doc) =>
            res.send @render "sequence",
                page: "sequence"
                sequence: doc

module.exports = SequenceController
