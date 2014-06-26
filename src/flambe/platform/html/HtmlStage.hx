//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Browser;
import js.html.*;

import flambe.display.Orientation;
import flambe.subsystem.StageSystem;
import flambe.util.Signal0;
import flambe.util.Value;

class HtmlStage
    implements StageSystem
{
    public var width (get, null) :Int;
    public var height (get, null) :Int;
    public var orientation (default, null) :Value<Orientation>;
    public var fullscreen (default, null) :Value<Bool>;
    public var fullscreenSupported (get, null) :Bool;

    public var resize (default, null) :Signal0;

    public var scaleFactor (default, null) :Float;

    public function new (canvas :CanvasElement)
    {
        _canvas = canvas;
        resize = new Signal0();

#if flambe_disable_html_retina
        scaleFactor = 1;
#else
        // If the DPI is being scaled by the browser, reverse it so that one canvas pixel equals
        // one screen pixel
        scaleFactor = computeScaleFactor();
        if (scaleFactor != 1) {
            Log.info("Reversing device DPI scaling", ["scaleFactor", scaleFactor]);
            HtmlUtil.setVendorStyle(_canvas, "transform-origin", "top left");
            HtmlUtil.setVendorStyle(_canvas, "transform", "scale(" + (1/scaleFactor) + ")");
        }
#end

#if !flambe_disable_autoresize
        if (HtmlUtil.SHOULD_HIDE_MOBILE_BROWSER) {
            Browser.window.addEventListener("orientationchange", function (_) {
                // Wait for the orientation change to finish... sigh
                HtmlUtil.callLater(hideMobileBrowser, 200);
            }, false);
            hideMobileBrowser();
        }

        Browser.window.addEventListener("resize", onWindowResize, false);
        onWindowResize(null);
#end

        orientation = new Value<Orientation>(null);
        if ((untyped Browser.window).orientation != null) {
            Browser.window.addEventListener("orientationchange", onOrientationChange, false);
            onOrientationChange(null);
        }

        fullscreen = new Value<Bool>(false);
        HtmlUtil.addVendorListener(Browser.document, "fullscreenchange", function (_) {
            updateFullscreen();
        }, false);
#if debug
        HtmlUtil.addVendorListener(Browser.document, "fullscreenerror", function (_) {
            // No useful error message since the event provides no reason. See the error conditions
            // at http://dvcs.w3.org/hg/fullscreen/raw-file/tip/Overview.html#dom-element-requestfullscreen
            Log.warn("Error when requesting fullscreen");
        }, false);
#end
        updateFullscreen();
    }

    public function get_width () :Int
    {
        return _canvas.width;
    }

    public function get_height () :Int
    {
        return _canvas.height;
    }

    public function get_fullscreenSupported () :Bool
    {
        return HtmlUtil.loadFirstExtension(
            ["fullscreenEnabled", "fullScreenEnabled"], Browser.document).value == true;
    }

    public function lockOrientation (orient :Orientation)
    {
        var lockOrientation = HtmlUtil.loadExtension("lockOrientation", Browser.window.screen).value;
        if (lockOrientation != null) {
            var htmlOrient = switch (orient) {
                case Portrait: "portrait";
                case Landscape: "landscape";
            };
            var allowed = Reflect.callMethod(Browser.window.screen, lockOrientation, [htmlOrient]);
            if (!allowed) {
                Log.warn("The request to lockOrientation() was refused by the browser");
            }
        }
    }

    public function unlockOrientation ()
    {
        var unlockOrientation = HtmlUtil.loadExtension("unlockOrientation", Browser.window.screen).value;
        if (unlockOrientation != null) {
            Reflect.callMethod(Browser.window.screen, unlockOrientation, []);
        }
    }

    public function requestResize (width :Int, height :Int)
    {
        if (resizeCanvas(width, height)) {
            // Fit the container to the requested canvas size
            var container = _canvas.parentElement;
            container.style.width = width + "px";
            container.style.height = height + "px";
        }
    }

    public function requestFullscreen (enable :Bool = true)
    {
        if (enable) {
            var documentElement = Browser.document.documentElement;
            var requestFullscreen = HtmlUtil.loadFirstExtension(
               ["requestFullscreen", "requestFullScreen"], documentElement).value;
            if (requestFullscreen != null) {
                Reflect.callMethod(documentElement, requestFullscreen, []);
            }

        } else {
            var cancelFullscreen = HtmlUtil.loadFirstExtension(
                ["cancelFullscreen", "cancelFullScreen"], Browser.document).value;
            if (cancelFullscreen != null) {
                Reflect.callMethod(Browser.document, cancelFullscreen, []);
            }
        }
    }

    private function onWindowResize (_)
    {
        // Resize the canvas to match its container's bounds
        var container = _canvas.parentElement;
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

        _canvas.width = Std.int(scaledWidth);
        _canvas.height = Std.int(scaledHeight);
        resize.emit();
        return true;
    }

    // Voodoo hacks required to move the address bar out of the way on Android and iOS
    private function hideMobileBrowser ()
    {
        // The maximum size of the part of the browser that can be scrolled away
        var mobileAddressBar = 100;

        var htmlStyle = Browser.document.documentElement.style;

        // Force the page to be tall enough to scroll
        htmlStyle.height = (Browser.window.innerHeight + mobileAddressBar) + "px";
        htmlStyle.width = Browser.window.innerWidth + "px";
        htmlStyle.overflow = "visible"; // Need to have overflow to scroll...

        HtmlUtil.callLater(function () {
            // Scroll the address bar away
            HtmlUtil.hideMobileBrowser();

            HtmlUtil.callLater(function () {
                // Fit the page to the new screen size
                htmlStyle.height = Browser.window.innerHeight + "px";

                onWindowResize(null);
            }, 100);
        });
    }

    private function onOrientationChange (_)
    {
        var value = HtmlUtil.orientation((untyped Browser.window).orientation);
        orientation._ = value;
    }

    private function updateFullscreen ()
    {
        var state :Dynamic = HtmlUtil.loadFirstExtension(
            ["fullscreen", "fullScreen", "isFullScreen"], Browser.document).value;
        fullscreen._ = (state == true); // state will be null if fullscreen not supported
    }

    private static function computeScaleFactor () :Float
    {
        // Based on "Delivering Web Content on High Resolution Displays"
        // https://developer.apple.com/videos/wwdc/2012/?id=602

        var devicePixelRatio = Browser.window.devicePixelRatio;
        if (devicePixelRatio == null) {
            devicePixelRatio = 1;
        }

        // Take into account any behind-the-scenes scaling of canvas elements
        var canvas = Browser.document.createCanvasElement();
        var ctx = canvas.getContext2d();
        var backingStorePixelRatio = HtmlUtil.loadExtension("backingStorePixelRatio", ctx).value;
        if (backingStorePixelRatio == null) {
            backingStorePixelRatio = 1;
        }

        // Calculate the scale, but bail early if this would cause the canvas to be larger than some
        // magic threshold. This was added to disable the retina display on the iPad 3, as
        // performance plummets there when scaling such a huge canvas
        var scale = devicePixelRatio / backingStorePixelRatio;
        var screenWidth = Browser.window.screen.width;
        var screenHeight = Browser.window.screen.height;
        if (scale*screenWidth > 1136 || scale*screenHeight > 1136) {
            return 1;
        }
        return scale;
    }

    private var _canvas :CanvasElement;
}
