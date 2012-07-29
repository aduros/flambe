//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Lib;

import flambe.animation.AnimatedFloat;
import flambe.util.Signal1;
import flambe.util.Value;
import flambe.web.Web;
import flambe.web.WebView;

class HtmlWeb
    implements Web
{
    public var supported (isSupported, null) :Bool;

    public function new (container :Dynamic)
    {
        _container = container;
    }

    public function isSupported () :Bool
    {
        return true;
    }

    public function createView (x :Float, y :Float, width :Float, height :Float) :WebView
    {
        var iframe = Lib.document.createElement("iframe");
        iframe.style.position = "absolute";
        iframe.style.border = "0";
        (untyped iframe).scrolling = "no";
        _container.appendChild(iframe);

        var view = new HtmlWebView(iframe, x, y, width, height);
        HtmlPlatform.instance.mainLoop.addTickable(view);
        return view;
    }

    private var _container :Dynamic;
}

class HtmlWebView
    implements WebView,
    implements Tickable
{
    public var url (default, null) :Value<String>;

    public var error (default, null) :Signal1<String>;

    public var x (default, null) :AnimatedFloat;
    public var y (default, null) :AnimatedFloat;
    public var width (default, null) :AnimatedFloat;
    public var height (default, null) :AnimatedFloat;

    public var iframe (default, null) :Dynamic;

    public function new (iframe :Dynamic, x :Float, y :Float, width :Float, height :Float)
    {
        this.iframe = iframe;

        var onBoundsChanged = function (_,_) updateBounds();
        this.x = new AnimatedFloat(x, onBoundsChanged);
        this.y = new AnimatedFloat(y, onBoundsChanged);
        this.width = new AnimatedFloat(width, onBoundsChanged);
        this.height = new AnimatedFloat(height, onBoundsChanged);
        updateBounds();

        url = new Value(null, function (url, _) loadUrl(url));
        error = new Signal1();
    }

    public function dispose ()
    {
        if (iframe == null) {
            return; // Already disposed
        }
        iframe.parentNode.removeChild(iframe);
        iframe = null;
    }

    public function update (dt :Float) :Bool
    {
        x.update(dt);
        y.update(dt);
        width.update(dt);
        height.update(dt);
        return (iframe == null);
    }

    private function updateBounds ()
    {
        if (iframe == null) {
            return; // Already disposed
        }
        iframe.style.left = x._ + "px";
        iframe.style.top = y._ + "px";
        iframe.width = width._;
        iframe.height = height._;
    }

    private function loadUrl (url :String)
    {
        if (iframe == null) {
            return; // Already disposed
        }
        iframe.src = url;
    }
}
