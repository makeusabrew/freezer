assert  = require "../../../test/lib/assert"
Helper  = require "../lib/helper"
server  = require("../../api").start 9876

Helper.host = "http://localhost:9876"

before (done) -> Helper.start done

describe "REST API - Sessions Resource", ->

  describe "GET /sessions", ->
    beforeEach (done) ->
      Helper.get "/sessions", done

    it "should return a 200 OK", ->
      assert.equal 200, Helper.getStatus()

    it "should return the correct body", ->
      data = Helper.getJSON()

      assert.equal 0, data.length

  describe "POST /sessions", ->

    describe "with invalid data", ->
      beforeEach (done) ->
        params = {}

        Helper.post "/sessions", params, done

      it "should return a 409 Conflict", ->
        assert.equal 409, Helper.getStatus()

    describe "with an invalid snapshot ID", ->
      beforeEach (done) ->
        params =
          path: "/foo/bar"
          snapshotId: "invalid"

        Helper.post "/sessions", params, done

      it "should return a 409 Conflict", ->
        assert.equal 409, Helper.getStatus()

    describe "with valid data", ->
      beforeEach (done) ->
        params =
          path: "/foo/bar"
          snapshotId: "9ed2b809d7446b9a0e000001"

        Helper.post "/sessions", params, done

      it "should return a 200 OK", ->
        assert.equal 200, Helper.getStatus()

      it "should return the correct body", ->
        data = Helper.getJSON()

        assert.equal "/foo/bar", data.path

        assert.ok data._id
        assert.ok data.created
        assert.ok data.updated

    describe.skip "with a path which is already in use", ->
      beforeEach (done) ->
        params =
          valid: "data"

        Helper.post "/sessions", params, done

      it "should return a 403 Forbidden", ->
        assert.equal 403, Helper.getStatus()

      describe "with the force flag set", ->
        beforeEach (done) ->
          params =
            force: true

          Helper.post "/sessions", params, done

        it "should return a 400 OK", ->
          assert.equal 200, Helper.getStatus()
