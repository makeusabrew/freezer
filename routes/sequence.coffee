SequenceController = require "../controllers/sequence"

action = (method) ->
    return (req, res) ->
        controller = new SequenceController
        controller[method](req, res)

module.exports = (app) ->
    app.get "/sequence/:id", action "view"
