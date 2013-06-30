//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Browser;
import js.html.*;

import haxe.Json;

class HtmlCatapultClient // extends CatapultClient
{
    public static function canUse ()
    {
        // Eventually this will be enabled in debug builds by default
#if flambe_enable_catapult
        // TODO(bruno): Detect websocket support
        return true;
#else
        return false;
#end
    }

    public function new ()
    {
        _socket = new WebSocket("ws://" + Browser.location.host);
        _socket.onerror = function (event) {
            Log.warn("Catapult error");
        };
        _socket.onopen = function (event) {
            Log.info("Catapult connected");
        };
        _socket.onmessage = function (event :MessageEvent) {
            trace("Got message!");
            trace(event.data);
            onMessage(Json.parse(event.data));
        };
        _loaders = [];
    }

    public function add (loader :BasicAssetPackLoader)
    {
        _loaders.push(loader);
    }

    private function onMessage (message :Dynamic)
    {
        switch (message.type) {
        case "file_changed":
            var url = message.name + "?v=" + message.md5;
            for (loader in _loaders) {
                loader.reload(url);
            }
        }
    }

    private var _socket :WebSocket;
    private var _loaders :Array<BasicAssetPackLoader>;
}
