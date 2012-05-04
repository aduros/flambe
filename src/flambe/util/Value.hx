//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;

import flambe.util.Signal2;

class Value<A>
    implements haxe.rtti.Generic // Generate typed templates in Flash
{
    public var _ (get, set) :A;
    public var changed (getChanged, null) :Signal2<A,A>;

    public function new (value :A, ?listener :Listener2<A,A>)
    {
        _value = value;
        if (listener != null) {
            _changed = new Signal2(listener);
        }
    }

    inline public function get () :A
    {
        return _value;
    }

    public function set (newValue :A) :A
    {
        var oldValue = _value;
        if (newValue != oldValue) {
            _value = newValue;
            if (_changed != null) {
                _changed.emit(newValue, oldValue);
            }
        }
        return newValue;
    }

    private function getChanged ()
    {
        if (_changed == null) {
            _changed = new Signal2();
        }
        return _changed;
    }

#if debug
    public function toString () :String
    {
        return cast _value;
    }
#end

    private var _value :A;
    private var _changed :Signal2<A,A>;
}
