//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.Lib;
import flash.external.ExternalInterface;
import flash.net.URLRequest;

class FlashWeb extends DummyWeb
{
    public function new ()
    {
        super();
    }

    override public function openBrowser (url :String)
    {
        if (ExternalInterface.available) {
            // Circumvent some browsers that block Flash popups even from a user input event
            ExternalInterface.call("window.open", url, "_blank");
        } else {
            Lib.getURL(new URLRequest(url), "_blank");
        }
    }
}
