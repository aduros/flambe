//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Lib;

class HtmlUtil
{
    public static function callLater (func :Void -> Void, delay :Int = 0)
    {
        (untyped Lib.window).setTimeout(func, delay);
    }

    public static function hideMobileBrowser ()
    {
        Lib.window.scrollTo(1, 0);
    }
}
