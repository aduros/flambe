//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.display.Stage;
import flash.events.ErrorEvent;
import flash.events.LocationChangeEvent;
import flash.geom.Rectangle;
import flash.media.StageWebView;

import flambe.animation.AnimatedFloat;
import flambe.subsystem.WebSystem;
import flambe.util.Signal1;
import flambe.util.Value;
import flambe.web.WebView;

class AirWeb extends FlashWeb
{
    public function new (stage :Stage)
    {
        super();
        _stage = stage;
    }

    public static function shouldUse () :Bool
    {
        return StageWebView.isSupported;
    }

    override public function get_supported () :Bool
    {
        return true;
    }

    override public function createView (x :Float, y :Float, width :Float, height :Float) :WebView
    {
        var nativeView = new StageWebView();
        nativeView.stage = _stage;

        var view = new AirWebView(nativeView, new Rectangle(x, y, width, height));
        FlashPlatform.instance.mainLoop.addTickable(view);
        return view;
    }

    private var _stage :Stage;
}

class AirWebView
    implements WebView
    implements Tickable
{
    public var url (default, null) :Value<String>;

    public var error (default, null) :Signal1<String>;

    public var x (default, null) :AnimatedFloat;
    public var y (default, null) :AnimatedFloat;
    public var width (default, null) :AnimatedFloat;
    public var height (default, null) :AnimatedFloat;

    public var nativeView (default, null) :StageWebView;

    public function new (nativeView :StageWebView, bounds :Rectangle)
    {
        this.nativeView = nativeView;
        _bounds = bounds;

        var onBoundsChanged = function (_,_) updateBounds();
        this.x = new AnimatedFloat(bounds.x, onBoundsChanged);
        this.y = new AnimatedFloat(bounds.y, onBoundsChanged);
        this.width = new AnimatedFloat(bounds.width, onBoundsChanged);
        this.height = new AnimatedFloat(bounds.height, onBoundsChanged);
        updateBounds();

        url = new Value<String>(null, onUrlChanged);
        error = new Signal1();

        nativeView.addEventListener(ErrorEvent.ERROR, onError);
        nativeView.addEventListener(LocationChangeEvent.LOCATION_CHANGING, onLocationChanging);
    }

    public function dispose ()
    {
        if (nativeView == null) {
            return; // Already disposed
        }
        nativeView.dispose();
        nativeView = null;
    }

    public function update (dt :Float) :Bool
    {
        x.update(dt);
        y.update(dt);
        width.update(dt);
        height.update(dt);
        return (nativeView == null);
    }

    private function updateBounds ()
    {
        if (nativeView == null) {
            return; // Already disposed
        }
        _bounds.x = x._;
        _bounds.y = y._;
        _bounds.width = width._;
        _bounds.height = height._;
        nativeView.viewPort = _bounds;
    }

    private function onUrlChanged (url :String, _)
    {
        if (nativeView == null || _suppressLoad) {
            return; // Already disposed
        }
        nativeView.loadURL(url);
    }

    private function onError (event :ErrorEvent)
    {
        error.emit(event.text);
    }

    private function onLocationChanging (event :LocationChangeEvent)
    {
        _suppressLoad = true;
        url._ = event.location;
        _suppressLoad = false;
    }

    private var _bounds :Rectangle;
    private var _suppressLoad :Bool;
}
