//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Lib;

class HtmlUtil
{
    public static var VENDOR_PREFIXES = [ "webkit", "moz", "ms", "o", "khtml" ];

    public static function callLater (func :Void -> Void, delay :Int = 0)
    {
        (untyped Lib.window).setTimeout(func, delay);
    }

    public static function hideMobileBrowser ()
    {
        Lib.window.scrollTo(1, 0);
    }

    // Load a prefixed vendor extension
    public static function loadExtension (name :String, ?obj :Dynamic) :Dynamic
    {
        if (obj == null) {
            obj = Lib.window;
        }

        // Try to load it as is
        var extension = Reflect.field(obj, name);
        if (extension != null) {
            return extension;
        }

        // Look through common vendor prefixes
        var capitalized = name.substr(0, 1).toUpperCase() + name.substr(1);
        for (prefix in VENDOR_PREFIXES) {
            var extension = Reflect.field(obj, prefix + capitalized);
            if (extension != null) {
                return extension;
            }
        }

        // Not found
        return null;
    }

    public static function setVendorStyle (element :Dynamic, name :String, value :String)
    {
        var style = element.style;
        for (prefix in VENDOR_PREFIXES) {
            style.setProperty("-" + prefix + "-" + name, value);
        }
        style.setProperty(name, value);
    }
}
