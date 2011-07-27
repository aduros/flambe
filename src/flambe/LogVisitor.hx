//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe;

import flambe.animation.Property;
import flambe.display.Sprite;

using flambe.display.Transform;
using flambe.display.Sprite;

class LogVisitor
    implements Visitor
{
    public function new ()
    {
        _comps = [];
        _depth = -1;
    }

    public function enterEntity (entity :Entity) :Bool
    {
        ++_depth;
        trace(tabs() + "( " + _comps.join(", ") + " )");
        _comps = [];
        return true;
    }

    public function leaveEntity (entity :Entity)
    {
        --_depth;
    }

    public function acceptComponent (comp :Component)
    {
        _comps.push(comp.getName());
    }

    private function tabs ()
    {
        var n = "";
        for (ii in 0..._depth) {
            n += "  ";
        }
        return n;
    }

    private var _depth :Int;
    private var _comps :Array<String>;
}
