//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.server;

import haxe.remoting.Context;
import haxe.Serializer;

import flambe.util.Logger;

class NodeRemoting
{
    private static var querystring = Node.require("querystring");

    public function new (ctx :Context, ?logger :Logger)
    {
        _ctx = ctx;
        _logger = logger;
    }

    // Called when an error occured while handling a remoting request
    public function onError (error :Dynamic)
    {
        if (_logger != null) {
            _logger.warn("Remoting exception",
                ["error", (error.stack != null) ? error.stack : error]);
        }
    }

    public function handle (req :Dynamic, res :Dynamic)
    {
        if (req.method != "POST" || req.headers[untyped "x-haxe-remoting"] != "1") {
            return false;
        }

        var body = "";
        req.on("data", function (chunk) body += chunk);
        req.on("end", function () {
            var relay = new NodeRelay(function (data :Dynamic) {
                res.end("hxr" + Serializer.run(data));
            });
            relay.onError = function (error :Dynamic) {
                var message = (error.message != null) ? error.message : error;
                var s = new haxe.Serializer();
                s.serializeException(message);
                res.end("hxr" + s.toString());

                onError(error);
            };

            res.setHeader("Content-Type", "text/plain");
            res.writeHead(200);
            try {
                var params = querystring.parse(body);
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
    private var _logger :Logger;
}
