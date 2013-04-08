//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.util.Disposable;

#if flash
import flash.events.IEventDispatcher;
import flash.events.Event;
#else
import js.html.EventTarget in IEventDispatcher;
import js.html.Event;
#end

private typedef Listener = Dynamic -> Void;

/**
 * Manages a group of event listeners. When the group is disposed, all listeners are removed.
 */
class EventGroup
    implements Disposable
{
    public function new ()
    {
        _entries = [];
    }

    /** Register a listener with this group. */
    public function addListener (dispatcher :IEventDispatcher, type :String, listener :Listener)
    {
        dispatcher.addEventListener(type, listener, false);
        _entries.push(new Entry(dispatcher, type, listener));
    }

    /** Register a listener with this group, all listeners are removed when it's fired. */
    public function addDisposingListener (
        dispatcher :IEventDispatcher, type :String, listener :Listener)
    {
        addListener(dispatcher, type, function (event :Event) {
            dispose();
            listener(event);
        });
    }

    /** Detach all listeners registered with this group. */
    public function dispose ()
    {
        for (entry in _entries) {
            entry.dispatcher.removeEventListener(entry.type, entry.listener, false);
        }
        _entries = [];
    }

    private var _entries :Array<Entry>;
}

private class Entry
{
    public var dispatcher :IEventDispatcher;
    public var type :String;
    public var listener :Listener;

    public function new (dispatcher, type, listener)
    {
        this.dispatcher = dispatcher;
        this.type = type;
        this.listener = listener;
    }
}
