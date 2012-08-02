<img src="https://raw.github.com/aduros/flambe/master/tools/embedder/logo.png" width="72" height="72" align="absmiddle"> Flambe
======

Flambe is an engine and asset pipeline for cross-platform multiplayer games.

Written in Haxe, games are compiled to Flash and HTML5, with support for mobile
devices. Server-side logic compiles to JS and runs on Node.js, for games that
require multiplayer.

Rendering in Flash uses Stage3D, falling back to copyPixels if hardware
accelerated Stage3D isn't available. The HTML5 renderer uses canvas, with plans
for WebGL support later on.

## Demos

Demos and more are on the [Flambe wiki].

## Overview

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

## Installing

See the [install guide] on the wiki.

## Hacking

To build and develop Flambe from source, clone this repository and run
`haxelib dev flambe ./src` to use it. Patches and pull requests are
welcome!

Are things not working? I'd be happy to help, open an [issue], ask on
the [forum], [email me] privately, or talk to me in #Haxe on
irc.freenode.net.

[![Build Status](https://secure.travis-ci.org/aduros/flambe.png?branch=master)](http://travis-ci.org/aduros/flambe)

[Flambe wiki]: https://github.com/aduros/flambe/wiki
[install guide]: https://github.com/aduros/flambe/wiki/Installation
[issue]: https://github.com/aduros/flambe/issues
[forum]: https://groups.google.com/forum/#!forum/flambe
[email me]: mailto:b@aduros.com
