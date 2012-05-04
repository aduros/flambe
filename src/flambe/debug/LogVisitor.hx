//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.debug;

/**
 * An visitor that traces out an entity hierarchy, for debugging.
 */
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
        if (_lastEntity != null && _lastEntity != entity) {
            print();
        }
        _lastEntity = entity;
        ++_depth;
        _comps = [];
        return true;
    }

    public function leaveEntity (entity :Entity)
    {
        if (_lastEntity == entity) {
            print();
        }
        _lastEntity = null;
        --_depth;
    }

    public function acceptComponent (comp :Component)
    {
        _comps.push(comp.getName());
    }

    private function print ()
    {
        var indent = "";
        for (ii in 0..._depth) {
            indent += "  ";
        }
        trace(indent + "( " + _comps.join(", ") + " )");
    }

    private var _depth :Int;
    private var _comps :Array<String>;
    private var _lastEntity :Entity;
}
