//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Lib;

import flambe.platform.Stage;
import flambe.util.Signal0;

class HtmlStage
    implements Stage
{
    public var width (getWidth, null) :Int;
    public var height (getHeight, null) :Int;

    public var resize (default, null) :Signal0;

    public function new (canvas :Dynamic)
    {
        _canvas = canvas;
        resize = new Signal0();

        // If probably running iOS or Android, try to keep the address bar hidden
        if (~/Mobile(\/.*)? Safari/.match(Lib.window.navigator.userAgent)) {
            (untyped Lib.window).addEventListener("orientationchange", function () {
                // Wait for the orientation change to finish... sigh
                HtmlUtil.callLater(onOrientationChange, 200);
            }, false);
            onOrientationChange();
        }

        (untyped Lib.window).addEventListener("resize", onResize, false);
        onResize();
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

    private function onResize ()
    {
        // Resize the canvas to match its container's bounds
        var container = _canvas.parentNode;
        var rect = container.getBoundingClientRect();

        if (_canvas.width != rect.width || _canvas.height != rect.height) {
            _canvas.width = rect.width;
            _canvas.height = rect.height;
            resize.emit();
        }
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

                onResize();
            }, 100);
        });
    }

    private var _canvas :Dynamic;
}
