assert  = require "../../../test/lib/assert"
Helper  = require "../lib/helper"
server  = require("../../api").start 9876

Helper.host = "http://localhost:9876"

before (done) -> Helper.start done

describe "REST API - Sequences Resource", ->

  beforeEach ->
    @sequence =
      _id: Helper._id "4ed2b809d7446b9a0e000014"
      url: "http://example.com/test"
      name: "A test sequence"
      created: new Date()

  describe "GET /sequences", ->

    describe "with a single resource in the collection", ->

      beforeEach (done) ->

        Helper.fixture sequence: [@sequence], ->
          Helper.get "/sequences", done

      it "should return a 200 OK", ->
        assert.equal 200, Helper.getStatus()

      it "should return the correct body", ->
        data = Helper.getJSON()

        assert.equal 1, data.length

        res = data[0]

        assert.equal "http://example.com/test", res.url
        assert.ok res._id

  describe "POST /sequences", ->
    beforeEach (done) ->
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
      beforeEach (done) ->
        Helper.get "/sequences/123456789012", done

      it "should return a 404 Not Found", ->
        assert.equal 404, Helper.getStatus()

      it "should return the correct body", ->
        data = Helper.getJSON()

        assert.equal "Resource not found", data.message

    describe "with an invalid ID string", ->
      before (done) ->
        Helper.get "/sequences/1234", done

      it "should return a 404 Not Found", ->
        assert.equal 404, Helper.getStatus()

      it "should return the correct body", ->
        data = Helper.getJSON()

        assert.equal "Resource not found", data.message

    describe "with a valid resource ID", ->
      beforeEach (done) ->
        Helper.fixture sequence: [@sequence], ->
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
      beforeEach (done) ->
        Helper.put "/sequences/123456789012", {}, done

      it "should return a 404 Not Found", ->
        assert.equal 404, Helper.getStatus()

    describe "with a valid resource ID", ->
      beforeEach (done) ->
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

    describe "with an invalid resource ID", ->

      beforeEach (done) ->
        Helper.delete "/sequences/123456789012", done

      it "should return a 200", ->
        assert.equal 200, Helper.getStatus()

      it "should return a deleted count of zero", ->
        data = Helper.getJSON()

        assert.equal 0, data.deleted

    describe "with a valid resource ID", ->

      beforeEach (done) ->
        Helper.fixture sequence: [@sequence], ->
          Helper.delete "/sequences/4ed2b809d7446b9a0e000014", done

      it "should return a 200", ->
        assert.equal 200, Helper.getStatus()

      it "should return a deleted count of one", ->
        data = Helper.getJSON()

        assert.equal 1, data.deleted
