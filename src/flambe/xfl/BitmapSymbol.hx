//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.xfl;

import haxe.xml.Fast;

import flambe.display.Sprite;
import flambe.display.Texture;

using flambe.util.Xmls;

class BitmapSymbol
    implements Symbol
{
    public var name (getName, null) :String;
    public var atlas (default, null) :Texture;
    public var x (default, null) :Float;
    public var y (default, null) :Float;
    public var width (default, null) :Float;
    public var height (default, null) :Float;
    public var anchorX (default, null) :Float;
    public var anchorY (default, null) :Float;

    public function new (reader :Fast, atlas :Texture)
    {
        _name = reader.att.name;

        this.atlas = atlas;
        x = reader.getFloatAttr("xAtlas");
        y = reader.getFloatAttr("yAtlas");
        width = reader.getFloatAttr("wAtlas");
        height = reader.getFloatAttr("hAtlas");
        anchorX = -reader.getFloatAttr("xOffset");
        anchorY = -reader.getFloatAttr("yOffset");
    }

    public function createSprite () :Sprite
    {
        return new BitmapSprite(this);
    }

    public function getName () :String
    {
        return _name;
    }

    private var _name :String;
}

