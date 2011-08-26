//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.server;

import haxe.remoting.Context;

class NodeRemoting
{
    public function new (ctx :Context)
    {
        _ctx = ctx;
    }

    public function handle (req :Dynamic, res :Dynamic)
    {
        if (req.method != "POST" || req.headers[untyped "x-haxe-remoting"] != "1") {
            return false;
        }

        req.addListener("data", function (buffer) {
            var relay = new NodeRelay(req);
            relay.success = function (data :Dynamic) {
                var s = new haxe.Serializer();
                s.serialize(data);
                res.end("hxr" + s.toString());
            };
            relay.error = function (err :Dynamic) {
                var message = (err.message != null) ? err.message : err;
                var stack = err.stack;

                // Log.info("Remoting error: " +
                //     (err.stack != null ? message + "\n" + err.stack : message));

                var s = new haxe.Serializer();
                s.serializeException(message);
                res.end("hxr" + s.toString());
            };

            res.writeHead(200);
            try {
                var params = _querystring.parse(buffer.toString());
                var requestData = params.__x;
                var u = new haxe.Unserializer(requestData);
                var path = u.unserialize();
                var args :Array<Dynamic> = u.unserialize();
                args.push(relay);
                _ctx.call(path,args);
            } catch (e :Dynamic) {
                relay.error(e);
            }
        });
        return true;
    }

    private var _ctx :Context;

    private static var _querystring = Node.require("querystring");
}
