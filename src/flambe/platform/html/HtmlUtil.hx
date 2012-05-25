//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Lib;

class HtmlUtil
{
    public static var VENDOR_PREFIXES = [ "webkit", "moz", "ms", "o", "khtml" ];

    /**
     * Whether the annoying scrolling address bar in some iOS and Android browsers may be hidden.
     */
    public static var SHOULD_HIDE_MOBILE_BROWSER =
        Lib.window.top == Lib.window &&
        ~/Mobile(\/.*)? Safari/.match(Lib.window.navigator.userAgent);

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

    // Loads a vendor extension and jams it into the supplied object
    public static function polyfill (name :String, ?obj :Dynamic) :Bool
    {
        if (obj == null) {
            obj = Lib.window;
        }

        var ext = loadExtension(name, obj);
        if (ext == null) {
            return false;
        }
        Reflect.setField(obj, name, ext);
        return true;
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
