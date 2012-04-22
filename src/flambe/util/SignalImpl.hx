//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;

using Lambda;

class SignalImpl
{
    public function new ()
    {
        _connections = [];
    }

    public function connect (listener :Dynamic, prioritize :Bool) :SignalConnection
    {
        var connection = new SignalConnection(this, listener);

        _connections = _connections.copy();
        if (prioritize) {
            _connections.unshift(connection);
        } else {
            _connections.push(connection);
        }

        return connection;
    }

    public function disconnect (connection :SignalConnection) :Bool
    {
        var idx = _connections.indexOf(connection);
        if (idx >= 0) {
            connection._internal_signal = null;
            connection._internal_listener = null;
            _connections = _connections.copy();
            _connections.splice(idx, 1);
            return true;
        }
        return false;
    }

    public function disconnectAll ()
    {
        for (connection in _connections) {
            connection._internal_signal = null;
            connection._internal_listener = null;
        }
        _connections = [];
    }

    public function emit (args :Array<Dynamic>)
    {
        var snapshot = _connections;
        for (connection in snapshot) {
            var listener = connection._internal_listener;

            // If the connection wasn't already disposed
            if (listener != null) {

                Reflect.callMethod(null, listener, args);

                // If this a once() connection, make sure it's removed
                if (!connection.stayInList) {
                    connection.dispose();
                }
            }
        }
    }

    inline public function hasListeners () :Bool
    {
        return _connections.length > 0;
    }

    public function clone () :SignalImpl
    {
        var copy = new SignalImpl();
        copy._connections = _connections.copy();
        return copy;
    }

    private var _connections :Array<SignalConnection>;
}
