<img src="https://raw.github.com/aduros/flambe/master/tools/embedder/logo.png" width="72" height="72" align="absmiddle"> Flambe
======

Flambe is an engine and asset pipeline for cross-platform multiplayer games.

Written in haXe, games are compiled to Flash and HTML5, with support for mobile devices. Server-side
logic compiles to JS and runs on node.js.

High level overview
-------------------

TODO! But for now, here are some philosophies I have been following for this project:

- Composition over inheritance.
- Convention over configuration.
- Rapid development, at most 2 seconds between making a code change and seeing the results.
- Mobile first, desktop second.

Building
--------

Flambe uses bleeding edge features in haXe, so you'll probably need a nightly build if you want to
try it out. This requirement will be removed once haXe 2.09 is released.

Pick up [Waf](https://code.google.com/p/waf/), cd into one of the [demos](https://github.com/aduros/flambe-demos), and:

    waf configure --debug
    waf install

Then open a browser to deploy/default/web/index.html. The Flash or HTML5 build will run depending
on what your browser best supports.

NOTE: Some of the demos require file parsing, which will throw a security error if loaded from
file://. To properly test, you should load from a real web server. One way to do this is `python -m
SimpleHTTPServer` then navigating to `localhost:8000`.

If Flambe detected Adobe AIR and the Android SDK, an APK will be installed to your device if you
have it plugged in.

What now, you ask? Documentation is slim, but the demos should be instructive. Once the dust
settles, I'll write some proper docs and a series of tutorials.

Are things not working? I'd be happy to help, send a message to ah.duros at gmail!
