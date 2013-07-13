//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Browser;
import js.html.*;

class HtmlCatapultClient extends CatapultClient
{
    public static function canUse () :Bool
    {
        return Reflect.hasField(Browser.window, "WebSocket");
    }

    public function new ()
    {
        super();

        _socket = new WebSocket("ws://" + Browser.location.host);
        _socket.onerror = function (event) {
            onError("unknown");
        };
        _socket.onopen = function (event) {
            Log.info("Catapult connected");
        };
        _socket.onmessage = function (event :MessageEvent) {
            onMessage(event.data);
        };
    }

    override private function onRestart ()
    {
        Browser.window.top.location.reload();
    }

    private var _socket :WebSocket;
}
