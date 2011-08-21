Flambe
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

Pick up [Waf](https://code.google.com/p/waf/), cd into one of the demos, and:

    waf configure --debug
    waf install

Then open a web browser to deploy/web/index.html
