//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe;

import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.display.Stage;
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
    public static var stage (getStage, null) :Stage;

    /**
     * The Storage subsystem, for persisting values.
     */
    public static var storage (getStorage, null) :Storage;

    /**
     * The Pointer subsystem, for mouse/touch events.
     */
    public static var pointer (getPointer, null) :Pointer;

    /**
     * The Mouse subsystem, for direct access to the mouse.
     */
    public static var mouse (getMouse, null) :Mouse;

    /**
     * The Touch subsystem, for direct access to the multi-touch.
     */
    public static var touch (getTouch, null) :Touch;

    /**
     * The Keyboard subsystem, for keyboard events.
     */
    public static var keyboard (getKeyboard, null) :Keyboard;

    /**
     * The Web subsystem, for using the device's web browser.
     */
    public static var web (getWeb, null) :Web;

    // TODO(bruno): Subsystems for touch, accelerometer, gamepads, haptic, geolocation, video,
    // textInput

    /**
     * Gets the RFC 4646 language tag of the environment. For example, "en-US", "pt", or null if the
     * locale is unknown.
     */
    public static var locale (getLocale, null) :String;

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
     * Creates a Logger for printing debug messages. In Flash, this uses the native trace()
     * function. In JS, logging goes to the console object. Logging is stripped from non-debug
     * builds.
     */
    inline public static function logger (tag :String) :Logger
    {
        // No need to assertCalledInit here, this should be callable from static initializers
        return new Logger(_platform.createLogHandler(tag));
    }

    inline private static function getStage () :Stage
    {
        #if debug assertCalledInit(); #end
        return _platform.stage;
    }

    inline private static function getStorage () :Storage
    {
        #if debug assertCalledInit(); #end
        return _platform.storage;
    }

    inline private static function getPointer () :Pointer
    {
        #if debug assertCalledInit(); #end
        return _platform.pointer;
    }

    inline private static function getMouse () :Mouse
    {
        #if debug assertCalledInit(); #end
        return _platform.mouse;
    }

    inline private static function getTouch () :Touch
    {
        #if debug assertCalledInit(); #end
        return _platform.touch;
    }

    inline private static function getKeyboard () :Keyboard
    {
        #if debug assertCalledInit(); #end
        return _platform.keyboard;
    }

    inline private static function getWeb () :Web
    {
        #if debug assertCalledInit(); #end
        return _platform.web;
    }

    inline private static function getLocale () :String
    {
        #if debug assertCalledInit(); #end
        return _platform.locale;
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
