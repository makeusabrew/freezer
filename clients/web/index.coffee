express   = require "express"
swig      = require "swig"
app       = express()

# app config
swig.init
  root: "#{__dirname}/views"
  allowErrors: true
  cache: false

app.configure ->
  app.use express.favicon()
  app.use express.bodyParser()
  app.use express.cookieParser()
  app.use express.cookieSession secret: "f51a8xlc3efeb869acbd7c2d962a4100x00a01f"
  app.use express.static "#{__dirname}/public"

# app includes
require("./routes")(app)

app.listen 8888
console.log "server listening on port 8888"
