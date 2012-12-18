//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe;

import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.display.Stage;
import flambe.display.Texture;
import flambe.input.Keyboard;
import flambe.input.Mouse;
import flambe.input.Pointer;
import flambe.input.Touch;
import flambe.platform.Platform;
import flambe.storage.Storage;
import flambe.util.Assert;
import flambe.util.Logger;
import flambe.util.Promise;
import flambe.util.Signal1;
import flambe.util.Value;
import flambe.web.Web;

/**
 * Provides access to all the different subsystems implemented on each platform.
 */
class System
{
    /**
     * The entity at the root of the hierarchy.
     */
    public static var root (default, null) :Entity = new Entity();

    /**
     * The Stage subsystem, for controlling the display viewport.
     */
    public static var stage (get_stage, null) :Stage;

    /**
     * The Storage subsystem, for persisting values.
     */
    public static var storage (get_storage, null) :Storage;

    /**
     * The Pointer subsystem, for unified mouse/touch events.
     */
    public static var pointer (get_pointer, null) :Pointer;

    /**
     * The Mouse subsystem, for direct access to the mouse.
     */
    public static var mouse (get_mouse, null) :Mouse;

    /**
     * The Touch subsystem, for direct access to the multi-touch.
     */
    public static var touch (get_touch, null) :Touch;

    /**
     * The Keyboard subsystem, for keyboard events.
     */
    public static var keyboard (get_keyboard, null) :Keyboard;

    /**
     * The Web subsystem, for using the device's web browser.
     */
    public static var web (get_web, null) :Web;

    // TODO(bruno): Subsystems for accelerometer, gamepads, haptic, geolocation, video, textInput

    /**
     * Gets the RFC 4646 language tag of the environment. For example, "en-US", "pt", or null if the
     * locale is unknown.
     */
    public static var locale (get_locale, null) :String;

    /**
     * Emitted when an uncaught exception occurs, if the platform supports it. You can wire this up
     * to your telemetry reporting service of choice.
     */
    public static var uncaughtError (default, null) :Signal1<String> = new Signal1<String>();

    /**
     * True when the app is not currently visible, such as when minimized or placed in a background
     * browser tab. While hidden, frame updates may be paused or throttled.
     */
    public static var hidden (default, null) :Value<Bool> = new Value<Bool>(false);

    /**
     * Gets the current clock time, in <b>seconds</b> since January 1, 1970. Depending on the
     * platform, this may be slightly more efficient than Date.now().getTime().
     */
    public static var time (get_time, null) :Float;

    /**
     * <p>Whether the app currently has a GPU context. In some renderers (Stage3D) the GPU and all
     * its resources may be destroyed at any time by the system. On renderers that don't need to
     * worry about reclaiming GPU resources (HTML5 canvas) this is always true.</p>
     *
     * <p>When this becomes false, all Textures and Graphics objects are destroyed and become
     * invalid. When it returns to true, apps should reload its textures.</p>
     */
    public static var hasGPU (default, null) :Value<Bool> = new Value<Bool>(false);

    /**
     * Starts up Flambe, this should usually be the first thing a game does.
     */
    public static function init ()
    {
        if (!_calledInit) {
            _platform.init();
            _calledInit = true;
        }
    }

    /**
     * Request to load an asset pack described by the given manifest.
     */
    inline public static function loadAssetPack (manifest :Manifest) :Promise<AssetPack>
    {
        #if debug assertCalledInit(); #end
        return _platform.loadAssetPack(manifest);
    }

    /**
     * Calls an external native function. When running in a browser, this calls a Javascript
     * function defined elsewhere on the page. When running in AIR, this will (not yet implemented)
     * call an AIR Native Extension.
     */
    inline public static function callNative (funcName :String, ?params :Array<Dynamic>) :Dynamic
    {
        #if debug assertCalledInit(); #end
        return _platform.callNative(funcName, params);
    }

    /**
     * Creates a new blank Texture, initialized to transparent black.
     */
    public static function createTexture (width :Int, height :Int) :Texture
    {
#if debug
        assertCalledInit();
        var texture = _platform.getRenderer().createEmptyTexture(width, height);
        if (texture == null) {
            Log.warn("Failed to create texture. Is the GPU context unavailable?");
        }
        return texture;
#else
        return _platform.getRenderer().createEmptyTexture(width, height);
#end
    }

    /**
     * Creates a Logger for printing debug messages. In Flash, this uses the native trace()
     * function. In JS, logging goes to the console object. Logging is stripped from non-debug
     * builds.
     */
    inline public static function createLogger (tag :String) :Logger
    {
        // No need to assertCalledInit here, this should be callable from static initializers
        return new Logger(_platform.createLogHandler(tag));
    }

    inline private static function get_time () :Float
    {
        #if debug assertCalledInit(); #end
        return _platform.getTime();
    }

    inline private static function get_stage () :Stage
    {
        #if debug assertCalledInit(); #end
        return _platform.getStage();
    }

    inline private static function get_storage () :Storage
    {
        #if debug assertCalledInit(); #end
        return _platform.getStorage();
    }

    inline private static function get_pointer () :Pointer
    {
        #if debug assertCalledInit(); #end
        return _platform.getPointer();
    }

    inline private static function get_mouse () :Mouse
    {
        #if debug assertCalledInit(); #end
        return _platform.getMouse();
    }

    inline private static function get_touch () :Touch
    {
        #if debug assertCalledInit(); #end
        return _platform.getTouch();
    }

    inline private static function get_keyboard () :Keyboard
    {
        #if debug assertCalledInit(); #end
        return _platform.getKeyboard();
    }

    inline private static function get_web () :Web
    {
        #if debug assertCalledInit(); #end
        return _platform.getWeb();
    }

    inline private static function get_locale () :String
    {
        #if debug assertCalledInit(); #end
        return _platform.getLocale();
    }

    private static function assertCalledInit ()
    {
        Assert.that(_calledInit, "You must call System.init() first");
    }

    private static var _platform :Platform =
#if flash
        flambe.platform.flash.FlashPlatform.instance;
#elseif html
        flambe.platform.html.HtmlPlatform.instance;
#else
        null;
#end

    private static var _calledInit = false;
}
