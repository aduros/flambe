//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;

import flambe.util.Signal2;

/**
 * Wraps a single value, notifying listeners when the value changes.
 */
#if !js
@:generic // Generate typed templates on static targets
#end
class Value<A>
{
    /**
     * The wrapped value, setting this to a different value will fire the `changed` signal.
     */
    public var _ (get, set) :A;

    /**
     * Emitted when the value has changed. The first listener parameter is the new current value,
     * the second parameter is the old previous value.
     */
    public var changed (get, null) :Signal2<A,A>;

    public function new (value :A, ?listener :Listener2<A,A>)
    {
        _value = value;
        _changed = (listener != null) ? new Signal2(listener) : null;
    }

    /**
     * Immediately calls a listener with the current value, and again whenever the value changes.
     * @returns A handle that can be disposed to stop watching for changes.
     */
    public function watch (listener :Listener2<A,A>) :Disposable
    {
        listener(_value, _value);
        return changed.connect(listener);
    }

    inline private function get__ () :A
    {
        return _value;
    }

    private function set__ (newValue :A) :A
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

    private function get_changed ()
    {
        if (_changed == null) {
            _changed = new Signal2();
        }
        return _changed;
    }

    #if debug @:keep #end public function toString () :String
    {
        return ""+_value;
    }

    private var _value :A;
    private var _changed :Signal2<A,A>;
}
