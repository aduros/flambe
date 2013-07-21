<img src="https://raw.github.com/aduros/flambe/master/command/data/scaffold/icons/72x72.png" width="72" height="72" align="absmiddle"> Flambe
======

Flambe is a 2D game engine that makes cross-platform development
actually fun!

Written in Haxe, games are compiled to HTML5 and Flash, with support for
mobile browsers. The HTML5 renderer uses WebGL, with fallback to canvas.
Rendering in Flash uses Stage3D. Native Android and iOS apps are
packaged using Adobe AIR.

## Demos

Demos and more are on the [Flambe wiki].

## Installing

See the [install guide] on the wiki.

## Hacking

Patches and pull requests are welcome! To build and develop Flambe from
source, clone this repository and run:

```
(sudo) npm link ./command
haxelib dev flambe ./src
```

To later go back to a stable release, run `(sudo) flambe update`.

`haxelib dev flambe /path/to/flambe/src` to use it. When you want to go
back to a stable release, run `haxelib dev flambe`.

Are things not working? I'd be happy to help, open an [issue], ask on
the [forum], [email me] privately, or talk to me in #Haxe on
irc.freenode.net.

[![Build Status](https://secure.travis-ci.org/aduros/flambe.png?branch=master)](http://travis-ci.org/aduros/flambe)
[![Selenium Test Status](https://saucelabs.com/buildstatus/flambe)](https://saucelabs.com/u/flambe)

[Flambe wiki]: https://github.com/aduros/flambe/wiki
[install guide]: https://github.com/aduros/flambe/wiki/Installation
[issue]: https://github.com/aduros/flambe/issues
[forum]: https://groups.google.com/forum/#!forum/flambe
[email me]: mailto:b@aduros.com
