//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;

class SignalBase
{
    private function new (listener :Dynamic)
    {
        _head = (listener != null) ? new SignalConnection(this, listener) : null;
        _deferredTasks = null;
    }

    /**
     * Whether this signal has at least one listener.
     */
    inline public function hasListeners () :Bool
    {
        return _head != null;
    }

    private function connectImpl (listener :Dynamic, prioritize :Bool) :SignalConnection
    {
        var conn = new SignalConnection(this, listener);
        if (dispatching()) {
            defer(function () {
                listAdd(conn, prioritize);
            });
        } else {
            listAdd(conn, prioritize);
        }
        return conn;
    }

    @:allow(flambe) function disconnect (conn :SignalConnection)
    {
        if (dispatching()) {
            defer(function () {
                listRemove(conn);
            });
        } else {
            listRemove(conn);
        }
    }

    private function defer (fn :Void->Void)
    {
        var tail = null, p = _deferredTasks;
        while (p != null) {
            tail = p;
            p = p.next;
        }

        var task = new Task(fn);
        if (tail != null) {
            tail.next = task;
        } else {
            _deferredTasks = task;
        }
    }

    private function willEmit () :SignalConnection
    {
        // Should never happen, since the public emit methods will defer, but just in case...
        Assert.that(!dispatching());

        var snapshot = _head;
        _head = DISPATCHING_SENTINEL;
        return snapshot;
    }

    private function didEmit (head :SignalConnection)
    {
        _head = head;

        var snapshot = _deferredTasks;
        _deferredTasks = null;
        while (snapshot != null) {
            snapshot.fn();
            snapshot = snapshot.next;
        }
    }

    private function listAdd (conn :SignalConnection, prioritize :Bool)
    {
        if (prioritize) {
            // Prepend it to the beginning of the list
            conn._next = _head;
            _head = conn;
        } else {
            // Append it to the end of the list
            var tail = null, p = _head;
            while (p != null) {
                tail = p;
                p = p._next;
            }
            if (tail != null) {
                tail._next = conn;
            } else {
                _head = conn;
            }
        }
    }

    private function listRemove (conn :SignalConnection)
    {
        var prev :SignalConnection = null, p = _head;
        while (p != null) {
            if (p == conn) {
                // Splice out p
                var next = p._next;
                if (prev == null) {
                    _head = next;
                } else {
                    prev._next = next;
                }
                return;
            }
            prev = p;
            p = p._next;
        }
    }

    inline private function dispatching () :Bool
    {
        return _head == DISPATCHING_SENTINEL;
    }

    private static var DISPATCHING_SENTINEL = new SignalConnection(null, null);

    private var _head :SignalConnection;
    private var _deferredTasks :Task;
}

private class Task
{
    public var fn :Void->Void;
    public var next :Task = null;

    public function new (fn :Void->Void)
    {
        this.fn = fn;
    }
}
