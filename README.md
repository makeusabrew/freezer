## Freezer - serving ice-cold JSON, just how you like it

Freezer attempts to take the pain out of building apps which consume
fast-changing JSON endpoints. It is best suited to projects which receive
data from sources outside of their control which is hard to reproduce but
important to code against.

It works by saving a copy of a given feed each time it changes, later
allowing fine-grained playback of those changes when *you* want them to
change. These changes can be initiated manually or programatically
to allow manual or automated testing against traditionally hard to capture,
hard to analyse, hard to control and hard to replay data.

## How?

Freezer is actually a collection of components divided loosely into client
and server applications. The client apps are not exhaustive but allow basic
use of the project as it was intended.

### Client apps

* **fetcher**: watches a given fully-qualified URL at a specified interval;
whenever the contents of that URL changes it writes a 'snapshot' of the file
to MongoDB with a timestamp and a checksum
* **cli**: given a URL which has some snapshots (created by the fetcher),
this app lets you manage which snapshot is served and when, as well as letting
you easily see the contents of and even diff snapshots
* **web**: not yet implemented, but a more user-friendly version of the CLI app
ideally allowing multiple sessions to be managed at once as well as adding
annotations to snapshots, splitting sequences, etc

### Server processes

* **freezer**: an HTTP server which maps inbound requests onto sequences currently
being managed (e.g. via the CLI app) and serves the relevant snapshot
* **api**: not implemented yet, a RESTful HTTP endpoint which will allow remote
clients to create sessions, sequences, snapshots etc. Primarily intended to
allow automated testing via external scripts.

## Usage

First of all, clone the repository and then run ```npm install``` in the root
of the project.

Next, start up the freezer:

```coffee ./server/run.coffee```

At present this will listen on all interfaces on port 9999. You can simply leave
this running - by all means use something like forever or supervisord if you wish.

Using the bundled client apps, the next thing to do is to start capturing some
'live' JSON. For example:

```coffee clients/fetcher.coffee http://api.bbcnews.appengine.co.uk/stories/world 60000```

Which will output something like:

    creating new sequence for http://api.bbcnews.appengine.co.uk/stories/world
    starting sequence 51aa2a9b6544e61a1a000001
    URL http://api.bbcnews.appengine.co.uk/stories/world, interval 60000, start hash null
    
    wrote snapshot 51aa2a9c6544e61a1a000002

This will fetch the BBC's top world stories every minute - though the interval can be as
low as you want it. Whenever the response differs to the last, a new snapshot will be
written to MongoDB. In the example above we hadn't fetched any content from this URL
before, so a new sequence was created and a snapshot was written immediately.

You can have as many fetchers running as many different URLs as you want.

Once you've got some snapshots captured you can run the rather crude cli app:

```coffee clients/cli.coffee http://api.bbcnews.appengine.co.uk/stories/world```

Which will output something like:

    Managing snapshots for sequence 51aa2a9b6544e61a1a000001
    URL: http://api.bbcnews.appengine.co.uk/stories/world
    Freezer server responding to requests on http://localhost:9999/stories/world

This tells the freezer process that the CLI app is currently responsible for which
snapshot of ```http://api.bbcnews.appengine.co.uk/stories/world``` the freezer
will serve until the CLI app exits. The URL these snapshots
are served on maps to the path of the original (e.g. ```/stories/world``` in
this case) - this allows transparent swapping of host names rather than entire
paths when testing (e.g. switching from a live endpoint to a snapshotted one
is usually a one-line config change).

Now when hitting ```http://localhost:9999/stories/world``` you'll be served
the first snapshot captured for that URL. As the CLI app is responsible for
what's served while it runs, we can change that:

    <= list
    1) Sat Jun 01 2013 18:08:44 GMT+0100 (BST) [✓]
    2) Sat Jun 01 2013 18:09:45 GMT+0100 (BST)
    3) Sat Jun 01 2013 18:14:49 GMT+0100 (BST)
    4) Sat Jun 01 2013 18:20:54 GMT+0100 (BST)
    5) Sat Jun 01 2013 18:30:01 GMT+0100 (BST)
    <= load 5
    Loading file 5... OK
    <= current
    Current snapshot: 5) Sat Jun 01 2013 18:30:01 GMT+0100 (BST) (51aa2f996544e61a1a000006)

And voila: each request to ```http://localhost:9999/stories/world``` will now serve
the contents of snapshot 5.

**Note** that use of the BBC's stories feed isn't a particularly good
example as it doesn't change much nor is it particularly complex. This
example could do with replacing with a faster, larger feed.

## License

The MIT License

Copyright (C) 2013 by Nick Payne <nick@kurai.co.uk>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE
