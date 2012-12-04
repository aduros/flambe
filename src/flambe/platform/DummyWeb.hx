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
    public var supported (get_supported, null) :Bool;

    public function new ()
    {
    }

    public function get_supported ()
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
