//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.nme;

import flash.Lib;
import flash.net.URLRequest;

class NMEWeb extends DummyWeb
{
    public function new ()
    {
        super();
    }

    override public function openBrowser (url :String)
    {
        Lib.getURL(new URLRequest(url), "_blank");
    }
}
