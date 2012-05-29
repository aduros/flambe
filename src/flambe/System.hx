//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe;

import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.display.Stage;
import flambe.input.Keyboard;
import flambe.input.Pointer;
import flambe.platform.Platform;
import flambe.storage.Storage;
import flambe.util.Logger;
import flambe.util.Promise;
import flambe.util.Signal1;
import flambe.util.Value;

class System
{
    /**
     * The entity at the root of the hierarchy.
     */
    public static var root /*(default, null)*/ = new Entity();

    public static var stage (getStage, null) :Stage;

    public static var storage (getStorage, null) :Storage;

    public static var pointer (getPointer, null) :Pointer;

    public static var keyboard (getKeyboard, null) :Keyboard;

    /**
     * Gets the RFC 4646 language tag of the environment. For example, "en-US", "pt", or null if the
     * locale is unknown.
     */
    public static var locale (getLocale, null) :String;

    // TODO(bruno): mouse, touch, accelerometer, gamepads, haptic, geolocation, video, web,
    // textInput

    /**
     * Emitted when an uncaught exception occurs, if the platform supports it. You can wire this up
     * to your telemetry reporting service of choice.
     */
    public static var uncaughtError /*(default, null)*/ = new Signal1<String>();

    /**
     * True when the app is not currently visible, such as when minimized or placed in a background
     * browser tab. While hidden, frame updates may be paused or throttled.
     */
    public static var hidden /*(default, null)*/ = new Value<Bool>(false);

    /**
     * Starts up Flambe, this should usually be the first thing a game does.
     */
    inline public static function init ()
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
        return _platform.loadAssetPack(manifest);
    }

    /**
     * Calls an external native function. When running in a browser, this calls a Javascript
     * function defined elsewhere on the page. When running in AIR, this will (not yet implemented)
     * call an AIR Native Extension.
     */
    inline public static function callNative (funcName :String, ?params :Array<Dynamic>) :Dynamic
    {
        return _platform.callNative(funcName, params);
    }

    /**
     * Creates a Logger for printing debug messages. In Flash, this uses the native trace()
     * function. In JS, logging goes to the console object. Logging is stripped from non-debug
     * builds.
     */
    inline public static function logger (tag :String) :Logger
    {
        return new Logger(_platform.createLogHandler(tag));
    }

    inline private static function getStage () :Stage
    {
        return _platform.stage;
    }

    inline private static function getStorage () :Storage
    {
        return _platform.storage;
    }

    inline private static function getPointer () :Pointer
    {
        return _platform.pointer;
    }

    inline private static function getKeyboard () :Keyboard
    {
        return _platform.keyboard;
    }

    inline private static function getLocale () :String
    {
        return _platform.locale;
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
