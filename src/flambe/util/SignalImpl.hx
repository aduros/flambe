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
            _connections = _connections.copy();
            _connections.splice(idx, 1);
            return true;
        }
        return false;
    }

    public function disconnectAll ()
    {
        for (ii in 0..._connections.length) {
            _connections[ii]._internal_signal = null;
        }
        _connections = [];
    }

    public function emit (args :Array<Dynamic>)
    {
        var snapshot = _connections;
        for (connection in snapshot) {
            Reflect.callMethod(null, connection._internal_listener, args);
            if (!connection.stayInList) {
                connection.dispose();
            }
        }
    }

    private var _connections :Array<SignalConnection>;
}
