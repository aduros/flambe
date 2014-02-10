<img src="https://raw.github.com/aduros/flambe/master/command/data/scaffold/icons/72x72.png" width="72" height="72" align="absmiddle"> Flambe
======

<a href="https://github.com/aduros/flambe/wiki/Showcase">
<img src="https://raw.github.com/wiki/aduros/flambe/images/showcase-montage.jpg" width="710" height="428">
</a>

Flambe is a 2D game engine that makes cross-platform development
actually fun!

Written in Haxe, games are compiled to HTML5 and Flash, with support for
mobile browsers. The HTML5 renderer uses WebGL, with fallback to canvas.
Rendering in Flash uses Stage3D. Native Android and iOS apps are
packaged using Adobe AIR.

On top of being high performance and cross-platform, Flambe recognizes
that assets and workflow are critical to game development. It includes
battle-tested support for importing Flash animations, bitmap fonts, and
particle systems. Live asset swapping lets you modify an asset and see
the change in your game automatically, *with no recompile or refresh*.
When you need to make a code change, Flambe recompiles and automatically
refreshes your browser tab, all in under 2 seconds.

Check out the [Flambe wiki] for demos and more.

## Installing

See the [install guide] on the wiki.

## Hacking

Patches and pull requests are welcome! To build and develop Flambe from
source, clone this repository and run:

```
(sudo) npm link ./command
haxelib dev flambe ./src
```

To later go back to a stable release, run `(sudo) flambe update` and
`haxelib dev flambe`.

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
