//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.swf;

import flambe.display.ImageSprite;
import flambe.display.Texture;

/**
 * Defines a flipbook-style movie, typically created from a spritesheet. Use
 * `Library.fromFlipbooks()` to create a Library from a list of Flipbooks.
 */
class Flipbook
{
    public var name (default, null) :String;
    public var frames (default, null) :Array<FlipbookFrame>;

    /**
     * @param name The name of the symbol that will be placed in the library.
     * @param textures The frames of the flipbook animation.
     */
    public function new<A:Texture> (name :String, textures :Array<A>)
    {
        this.name = name;

        // By default, play the animation for one second
        var durationPerFrame = 1 / textures.length;

        frames = [];
        for (texture in textures) {
            frames.push(new FlipbookFrame(texture, durationPerFrame));
        }
    }

    /**
     * Uniformly sets the duration for all frames in this flipbook, so that the entire movie takes
     * the given duration.
     *
     * @param duration The movie duration, in seconds.
     * @returns This instance, for chaining.
     */
    public function setDuration (duration :Float) :Flipbook
    {
        var durationPerFrame = duration / frames.length;
        for (frame in frames) {
            frame.duration = durationPerFrame;
        }
        return this;
    }

    /**
     * Sets the anchor point for all frames in this flipbook.
     *
     * @returns This instance, for chaining.
     */
    public function setAnchor (x :Float, y :Float) :Flipbook
    {
        for (frame in frames) {
            frame.anchorX = x;
            frame.anchorY = y;
        }
        return this;
    }
}

class FlipbookFrame
{
    /** The texture shown during this frame. */
    public var texture :Texture;

    /** How long to show this frame, in seconds. */
    public var duration :Float;

    /** The X position of this frame's anchor point. */
    public var anchorX :Float = 0;

    /** The Y position of this frame's anchor point. */
    public var anchorY :Float = 0;

    public var label :String = null;

    @:allow(flambe) function new (texture :Texture, duration :Float)
    {
        this.texture = texture;
        this.duration = duration;
    }

    @:allow(flambe) function toSymbol () :Symbol
    {
        return new FrameSymbol(this);
    }
}

private class FrameSymbol
    implements Symbol
{
    public var name (get, null) :String;

    public function new (frame :FlipbookFrame)
    {
        _texture = frame.texture;
        _anchorX = frame.anchorX;
        _anchorY = frame.anchorY;
    }

    public function createSprite () :ImageSprite
    {
        var sprite = new ImageSprite(_texture);
        sprite.setAnchor(_anchorX, _anchorY);
        return sprite;
    }

    private function get_name () :String
    {
        return null;
    }

    private var _texture :Texture;
    private var _anchorX :Float;
    private var _anchorY :Float;
}
