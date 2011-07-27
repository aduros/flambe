//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

import flambe.animation.Property;

class Transform extends Component
{
    public var x (default, null) :PFloat;
    public var y (default, null) :PFloat;
    public var rotation (default, null) :PFloat;
    public var scaleX (default, null) :PFloat;
    public var scaleY (default, null) :PFloat;

    public function new ()
    {
        x = new PFloat(0);
        y = new PFloat(0);
        rotation = new PFloat(0);
        scaleX = new PFloat(1);
        scaleY = new PFloat(1);
    }

    override public function onUpdate (dt :Int)
    {
        x.update(dt);
        y.update(dt);
        rotation.update(dt);
        scaleX.update(dt);
        scaleY.update(dt);
    }

    public function distanceTo (x :Float, y :Float) :Float
    {
        var dx = x - this.x._;
        var dy = y - this.y._;
        return Math.sqrt(dx*dx + dy*dy);
    }
}
