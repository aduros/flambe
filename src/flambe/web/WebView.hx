//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.web;

import flambe.animation.AnimatedFloat;
import flambe.util.Disposable;
import flambe.util.Signal1;
import flambe.util.Value;

/**
 * Displays a web page over the stage. In the HTML target, this is implemented with an iframe. In
 * AIR, it uses StageWebView. On Android, make sure your app manifest contains the INTERNET
 * permission.
 */
interface WebView extends Disposable
{
    /**
     * The URL currently being displayed. Can be set to load a different URL. In AIR, this value
     * will change automatically if the user navigates to a different page.
     */
    var url (default, null) :Value<String>;

    /**
     * An error message emitted if the page could not be loaded.
     */
    var error (default, null) :Signal1<String>;

    /**
     * Viewport X position, in pixels.
     */
    var x (default, null) :AnimatedFloat;

    /**
     * Viewport Y position, in pixels.
     */
    var y (default, null) :AnimatedFloat;

    /**
     * Viewport width, in pixels.
     */
    var width (default, null) :AnimatedFloat;

    /**
     * Viewport height, in pixels.
     */
    var height (default, null) :AnimatedFloat;
}
