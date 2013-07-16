//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.Lib;
import flash.events.ErrorEvent;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.external.ExternalInterface;
import flash.net.Socket;

class FlashCatapultClient extends CatapultClient
{
    public static function canUse () :Bool
    {
        return #if air false #else true #end;
    }

    public function new ()
    {
        super();

        var re = ~/^http(s?):\/\/(.*?)(:(\d+))?\/.*/;
        if (re.match(Lib.current.loaderInfo.loaderURL)) {
            var host = re.matched(2);
            var port = re.matched(4);
            if (port == null) {
                port = "80";
            }

            _socket = new Socket();
            _socket.addEventListener(ProgressEvent.SOCKET_DATA, function (event :ProgressEvent) {
                var message = _socket.readUTFBytes(_socket.bytesAvailable);
                onMessage(message);
            });
            _socket.addEventListener(IOErrorEvent.IO_ERROR, function (event :ErrorEvent) {
                onError(event.text);
            });
            _socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function (event :ErrorEvent) {
                onError(event.text);
            });
            _socket.connect(host, Std.parseInt(port)+1);

        } else {
            onError("Couldn't determine host/port");
        }
    }

    override private function onRestart ()
    {
        ExternalInterface.call("window.top.location.reload");
    }

    private var _socket :Socket;
}
