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
            _connections[idx] = null;
            connection._internal_signal = null;
            return true;
        }
        return false;
    }

    public function disconnectAll ()
    {
        for (ii in 0..._connections.length) {
            _connections[ii] = null;
        }
        _connections = [];
    }

    public function emit (args :Array<Dynamic>)
    {
        var ii = 0;
        while (ii < _connections.length) {
            var connection = _connections[ii];
            if (connection != null) {
                Reflect.callMethod(null, connection._internal_listener, args);
            }
            if (connection == null || !connection.stayInList) {
                _connections.splice(ii, 1);
            } else {
                ++ii;
            }
        }
    }

    private var _connections :Array<SignalConnection>;
}
