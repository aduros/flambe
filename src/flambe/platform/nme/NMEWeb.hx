//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.nme;

import nme.Lib;
import nme.net.URLRequest;

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
