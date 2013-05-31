HomeController = require "../controllers/home"

action = (method) ->
    return (req, res) ->
        controller = new HomeController
        controller[method](req, res)

module.exports = (app) ->
    app.get "/", action "home"

    # external routes here...
    # require("./sequences")(app)
