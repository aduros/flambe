//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Lib;

import flambe.display.Orientation;
import flambe.display.Stage;
import flambe.util.Signal0;

class HtmlStage
    implements Stage
{
    private static var log = Log.log; // http://code.google.com/p/haxe/issues/detail?id=365

    public var width (getWidth, null) :Int;
    public var height (getHeight, null) :Int;

    public var resize (default, null) :Signal0;

    public var devicePixelRatio (default, null) :Float;

    public function new (canvas :Dynamic)
    {
        _canvas = canvas;
        resize = new Signal0();

        devicePixelRatio = (untyped window).devicePixelRatio;
        if (devicePixelRatio == null) {
            devicePixelRatio = 1;
        }

        // If the DPI is being scaled by the browser, reverse it so that one canvas pixel equals
        // one screen pixel
        if (devicePixelRatio != 1) {
            log.info("Reversing device DPI scaling", ["devicePixelRatio", devicePixelRatio]);
            HtmlUtil.setVendorStyle(_canvas, "transform-origin", "top left");
            HtmlUtil.setVendorStyle(_canvas, "transform", "scale(" + (1/devicePixelRatio) + ")");
        }

#if !flambe_disable_autoresize
        if (HtmlUtil.SHOULD_HIDE_MOBILE_BROWSER) {
            (untyped Lib.window).addEventListener("orientationchange", function () {
                // Wait for the orientation change to finish... sigh
                HtmlUtil.callLater(onOrientationChange, 200);
            }, false);
            onOrientationChange();
        }

        (untyped Lib.window).addEventListener("resize", onWindowResize, false);
        onWindowResize();
#end
    }

    public function getWidth () :Int
    {
        return _canvas.width;
    }

    public function getHeight () :Int
    {
        return _canvas.height;
    }

    public function lockOrientation (orient :Orientation)
    {
        // Nothing until mobile browsers support it
    }

    public function requestResize (width :Int, height :Int)
    {
        if (resizeCanvas(width, height)) {
            // Fit the container to the requested canvas size
            var container = _canvas.parentNode;
            container.style.width = width + "px";
            container.style.height = height + "px";
        }
    }

    private function onWindowResize ()
    {
        // Resize the canvas to match its container's bounds
        var container = _canvas.parentNode;
        var rect = container.getBoundingClientRect();
        resizeCanvas(rect.width, rect.height);
    }

    private function resizeCanvas (width :Float, height :Float) :Bool
    {
        // Take device scaling into account...
        var scaledWidth = devicePixelRatio*width;
        var scaledHeight = devicePixelRatio*height;

        if (_canvas.width == scaledWidth && _canvas.height == scaledHeight) {
            return false;
        }

        _canvas.width = scaledWidth;
        _canvas.height = scaledHeight;
        resize.emit();
        return true;
    }

    // Voodoo hacks required to move the address bar out of the way on Android and iOS
    private function onOrientationChange ()
    {
        // The maximum size of the part of the browser that can be scrolled away
        var mobileAddressBar = 100;

        var htmlStyle = (untyped Lib.document).documentElement.style;

        // Force the page to be tall enough to scroll
        htmlStyle.height = (Lib.window.innerHeight + mobileAddressBar) + "px";
        htmlStyle.width = Lib.window.innerWidth + "px";
        htmlStyle.overflow = "visible"; // Need to have overflow to scroll...

        HtmlUtil.callLater(function () {
            // Scroll the address bar away
            HtmlUtil.hideMobileBrowser();

            HtmlUtil.callLater(function () {
                // Fit the page to the new screen size
                htmlStyle.height = Lib.window.innerHeight + "px";

                onWindowResize();
            }, 100);
        });
    }

    private var _canvas :Dynamic;
}
