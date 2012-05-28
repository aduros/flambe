<img src="https://raw.github.com/aduros/flambe/master/tools/embedder/logo.png" width="72" height="72" align="absmiddle"> Flambe
======

Flambe is an engine and asset pipeline for cross-platform multiplayer games.

Written in Haxe, games are compiled to Flash and HTML5, with support for mobile
devices. Server-side logic compiles to JS and runs on node.js.

High level overview
-------------------

TODO! But for now, here are some philosophies I have been following for this
project:

- Composition over inheritance.
- Convention over configuration.
- Rapid development, at most 2 seconds between making a code change and seeing
  the results.
- Mobile first, desktop second.

Building
--------

Make sure you have Haxe 2.09, pick up [Waf](https://code.google.com/p/waf/), cd
into one of the [demos](https://github.com/aduros/flambe-demos), and:

    waf configure --debug
    waf install

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
message](https://github.com/aduros)!
