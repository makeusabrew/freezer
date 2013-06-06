assert  = require "../../../test/lib/assert"
Helper  = require "../lib/helper"
server  = require("../../api").start 9876

Helper.host = "http://localhost:9876"

describe "REST API - Sequences Resource", ->
  before (done) ->
    Helper.start done

  describe "GET /sequences", ->
    before (done) ->
      Helper.get "/sequences", done

    it "should return a 200 OK", ->
      assert.equal 200, Helper.getStatus()

    it "should return the correct body", ->
      data = Helper.getJSON()

      assert.equal 1, data.length

      res = data[0]

      assert.equal "http://example.com/test", res.url

  describe "POST /sequences", ->
    before (done) ->
      params =
        url: "http://foo.com"
        name: "foo"

      Helper.post "/sequences", params, done

    # @TODO should this *actually* be a 201 created?
    it "should return a 200 OK", ->
      assert.equal 200, Helper.getStatus()

    it "should return the correct body", ->
      data = Helper.getJSON()

      assert.equal "http://foo.com", data.url
      assert.equal "foo", data.name

      assert.ok data._id
      assert.ok data.created

  describe "GET /sequences/:id", ->
    describe "with an invalid resource ID", ->
      before (done) ->
        Helper.get "/sequences/123456789012", done

      it "should return a 404 Not Found", ->
        assert.equal 404, Helper.getStatus()

      it "should return the correct body", ->
        data = Helper.getJSON()

        assert.equal "Resource not found", data.message

    describe "with an invalid ID string", ->
      before (done) ->
        Helper.get "/sequences/1234", done

      # @TODO: really? a 500?
      it "should return a 500", ->
        assert.equal 500, Helper.getStatus()

      it "should return the correct body", ->
        data = Helper.getJSON()

        assert.equal "Argument passed in must be a single String of 12 bytes or a string of 24 hex characters", data.message

    describe "with a valid resource ID", ->
      before (done) ->
        Helper.get "/sequences/4ed2b809d7446b9a0e000014", done

      it "should return a 200", ->
        assert.equal 200, Helper.getStatus()

      it "should return the correct body", ->
        data = Helper.getJSON()

        assert.equal "http://example.com/test", data.url
        assert.equal "A test sequence", data.name
        assert.equal "4ed2b809d7446b9a0e000014", data._id

  describe "PUT /sequences/:id", ->
    describe "with an invalid resource ID", ->
      before (done) ->
        Helper.put "/sequences/123456789012", {}, done

      it "should return a 404 Not Found", ->
        assert.equal 404, Helper.getStatus()

    describe "with a valid resource ID", ->
      before (done) ->
        params =
          url: "http://new.com"
          name: "New name"

        Helper.put "/sequences/4ed2b809d7446b9a0e000014", params, done

      it "should return a 200", ->
        assert.equal 200, Helper.getStatus()

      it "should return the correct body", ->
        data = Helper.getJSON()

        assert.equal "http://new.com", data.url
        assert.equal "New name", data.name

  describe "DELETE /sequences/:id", ->
    ###
    describe "with an invalid resource ID", ->
      before (done) ->
        Helper.delete "/sequences/123456789012", done

      it "should return a 404 Not Found", ->
        assert.equal 404, Helper.getStatus()
    ###

    describe "with a valid resource ID", ->
      before (done) ->
        Helper.delete "/sequences/4ed2b809d7446b9a0e000014", done

      it "should return a 200", ->
        assert.equal 200, Helper.getStatus()

      it "should return the correct body", ->
        data = Helper.getJSON()

        assert.equal 1, data.deleted
