//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.util.Assert;
import flambe.web.Web;
import flambe.web.WebView;

class DummyWeb
    implements Web
{
    public var supported (isSupported, null) :Bool;

    public function new ()
    {
    }

    public function isSupported ()
    {
        return false;
    }

    public function createView (x :Float, y :Float, width :Float, height :Float) :WebView
    {
        Assert.fail("Web.createView is unsupported in this environment, check the `supported` flag.");
        return null;
    }

    public function openBrowser (url :String)
    {
        // Nothing
    }
}
