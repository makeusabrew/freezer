Freezer       = require "../lib/client"
FreezerServer = require "./freezer"
ApiServer     = require "./api"

Freezer.start ->
  FreezerServer.start process.argv[2] || 9999
  ApiServer.start process.argv[3] || 9898
