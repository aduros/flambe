<img src="https://raw.github.com/aduros/flambe/master/tools/embedder/logo.png" width="72" height="72" align="absmiddle"> Flambe
======

Flambe is an engine and asset pipeline for cross-platform multiplayer games.

Written in Haxe, games are compiled to Flash and HTML5, with support for mobile
devices. Server-side logic compiles to JS and runs on Node.js, for games that
require multiplayer.

Rendering in Flash uses Stage3D, falling back to copyPixels if hardware accelerated
Stage3D isn't available. The HTML5 renderer uses canvas, with plans for WebGL
support later on.

Overview
--------

Flambe's design and roadmap are guided by a few philosophies:

- Composition over inheritance: Flambe uses an entity/component system rather
  than sprawling inheritance hierarchies. The composition pattern also comes up
  repeatedly in other parts of Flambe's design.

- Convention over configuration: Project layouts and APIs should have sensible
  defaults. Manual configuration for unusual use cases should be possible, but
  not required.

- HTML5 and mobile web support is a high priority.

- Flambe is a "clean break" from the Flash API which most Haxe game engines are
  based on. The Flash API and its many quirks are a huge amount of work to
  reliably port to other platforms (ask the NME guys) and wasn't designed to run
  well on GPUs (ask the Starling guys). By writing against a smaller,
  well-defined API designed for games, Flambe games can be much more portable,
  optimized, and developed more rapidly.

Building
--------

(These instructions will work when I put Flambe up on haxelib, soon)

Download and setup Flambe by running:

    haxelib install flambe
    haxelib run flambe setup

Then cd into one of the [demos](https://github.com/aduros/flambe-demos), and:

    flambe-waf configure --debug
    flambe-waf install

Then open a browser to deploy/web/index.html. The Flash or HTML5 build will run
depending on what your browser best supports.

NOTE: Some of the demos require file parsing, which will throw a security error
if loaded from file://. To properly test, you should load from a real web
server. One way to do this is `python -m SimpleHTTPServer` then navigating
to `localhost:8000/index.html`.

If Flambe detected Adobe AIR and the Android SDK, an APK will be installed to
your device if you have it plugged in.

What now, you ask? Documentation is slim, but the demos should be instructive.
Once the dust settles, I'll write some proper docs and a series of tutorials.

Are things not working? I'd be happy to help, [send me a
message](https://github.com/aduros) or chat to me in #Haxe on irc.freenode.net.

[![Build Status](https://secure.travis-ci.org/aduros/flambe.png?branch=master)](http://travis-ci.org/aduros/flambe)
