//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Lib;

import flambe.display.Orientation;
import flambe.display.Stage;
import flambe.util.Signal0;
import flambe.util.Value;

class HtmlStage
    implements Stage
{
    public var width (getWidth, null) :Int;
    public var height (getHeight, null) :Int;
    public var orientation (default, null) :Value<Orientation>;
    public var fullscreen (default, null) :Value<Bool>;
    public var fullscreenSupported (isFullscreenSupported, null) :Bool;

    public var resize (default, null) :Signal0;

    public var scaleFactor (default, null) :Float;

    public function new (canvas :Dynamic)
    {
        _canvas = canvas;
        resize = new Signal0();

        // If the DPI is being scaled by the browser, reverse it so that one canvas pixel equals
        // one screen pixel
        scaleFactor = computeScaleFactor(canvas);
        if (scaleFactor != 1) {
            Log.info("Reversing device DPI scaling", ["scaleFactor", scaleFactor]);
            HtmlUtil.setVendorStyle(_canvas, "transform-origin", "top left");
            HtmlUtil.setVendorStyle(_canvas, "transform", "scale(" + (1/scaleFactor) + ")");
        }

#if !flambe_disable_autoresize
        if (HtmlUtil.SHOULD_HIDE_MOBILE_BROWSER) {
            (untyped window).addEventListener("orientationchange", function () {
                // Wait for the orientation change to finish... sigh
                HtmlUtil.callLater(hideMobileBrowser, 200);
            }, false);
            hideMobileBrowser();
        }

        (untyped window).addEventListener("resize", onWindowResize, false);
        onWindowResize();
#end

        orientation = new Value<Orientation>(null);
        if ((untyped window).orientation != null) {
            (untyped window).addEventListener("orientationchange", onOrientationChange, false);
            onOrientationChange();
        }

        fullscreen = new Value<Bool>(false);
        HtmlUtil.addVendorListener(Lib.document, "fullscreenchange", function (_) {
            updateFullscreen();
        }, false);
#if debug
        HtmlUtil.addVendorListener(Lib.document, "fullscreenerror", function (_) {
            // No useful error message since the event provides no reason. See the error conditions
            // at http://dvcs.w3.org/hg/fullscreen/raw-file/tip/Overview.html#dom-element-requestfullscreen
            Log.warn("Error when requesting fullscreen");
        }, false);
#end
        updateFullscreen();
    }

    public function getWidth () :Int
    {
        return _canvas.width;
    }

    public function getHeight () :Int
    {
        return _canvas.height;
    }

    public function isFullscreenSupported () :Bool
    {
        return HtmlUtil.loadFirstExtension(
            ["fullscreenEnabled", "fullScreenEnabled"], Lib.document).value == true;
    }

    public function lockOrientation (orient :Orientation)
    {
        // Nothing until mobile browsers support it
    }

    public function unlockOrientation ()
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

    public function requestFullscreen (enable :Bool = true)
    {
        if (enable) {
            var documentElement = untyped Lib.document.documentElement;
            var requestFullscreen = HtmlUtil.loadFirstExtension(
               ["requestFullscreen", "requestFullScreen"], documentElement).value;
            if (requestFullscreen != null) {
                Reflect.callMethod(documentElement, requestFullscreen, []);
            }

        } else {
            var cancelFullscreen = HtmlUtil.loadFirstExtension(
                ["cancelFullscreen", "cancelFullScreen"], Lib.document).value;
            if (cancelFullscreen != null) {
                Reflect.callMethod(Lib.document, cancelFullscreen, []);
            }
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
        var scaledWidth = scaleFactor*width;
        var scaledHeight = scaleFactor*height;

        if (_canvas.width == scaledWidth && _canvas.height == scaledHeight) {
            return false;
        }

        _canvas.width = scaledWidth;
        _canvas.height = scaledHeight;
        resize.emit();
        return true;
    }

    // Voodoo hacks required to move the address bar out of the way on Android and iOS
    private function hideMobileBrowser ()
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

    private function onOrientationChange ()
    {
        var value = HtmlUtil.orientation((untyped window).orientation);
        orientation._ = value;
    }

    private function updateFullscreen ()
    {
        var state :Dynamic = HtmlUtil.loadFirstExtension(
            ["fullscreen", "fullScreen", "isFullScreen"], Lib.document).value;
        fullscreen._ = (state == true); // state will be null if fullscreen not supported
    }

    private static function computeScaleFactor (canvas :Dynamic) :Float
    {
        // Based on "Delivering Web Content on High Resolution Displays"
        // https://developer.apple.com/videos/wwdc/2012/?id=602

        var devicePixelRatio = (untyped window).devicePixelRatio;
        if (devicePixelRatio == null) {
            devicePixelRatio = 1;
        }

        // Take into account any behind-the-scenes scaling of the canvas element
        var ctx = canvas.getContext("2d");
        var backingStorePixelRatio = HtmlUtil.loadExtension("backingStorePixelRatio", ctx).value;
        if (backingStorePixelRatio == null) {
            backingStorePixelRatio = 1;
        }

        // Calculate the scale, but bail early if this would cause the canvas to be larger than some
        // magic threshold. This was added to disable the retina display on the iPad 3, as
        // performance plummets there when scaling such a huge canvas
        var scale = devicePixelRatio / backingStorePixelRatio;
        var screenWidth = (untyped screen).width;
        var screenHeight = (untyped screen).height;
        if (scale*screenWidth > 1024 || scale*screenHeight > 1024) {
            return 1;
        }
        return scale;
    }

    private var _canvas :Dynamic;
}
