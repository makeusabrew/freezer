Freezer        = require "../lib/freezer"
SnapshotServer = require "./snapshot"
ApiServer      = require "./api"

Freezer.start ->
  SnapshotServer.start process.argv[2] || 9999
  ApiServer.start process.argv[3] || 9898
