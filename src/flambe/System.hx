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

class System
{
    public static var root /*(default, null)*/ = new Entity();

    public static var stage (getStage, null) :Stage;

    public static var storage (getStorage, null) :Storage;

    public static var pointer (getPointer, null) :Pointer;

    public static var keyboard (getKeyboard, null) :Keyboard;

    public static var locale (getLocale, null) :String;

    // TODO(bruno): mouse, touch, accelerometer, gamepads, haptic, geolocation, video, web,
    // textInput

    /**
     * Emitted when an uncaught exception occurs, if the platform supports it. You can wire this up
     * to your telemetry reporting service of choice.
     */
    public static var uncaughtError /*(default, null)*/ = new Signal1<String>();

    inline public static function init ()
    {
        if (!_calledInit) {
            _platform.init();
            _calledInit = true;
        }
    }

    // A bunch of short-hands to driver functions

    inline public static function loadAssetPack (manifest :Manifest) :Promise<AssetPack>
    {
        return _platform.loadAssetPack(manifest);
    }

    inline public static function callNative (funcName :String, ?params :Array<Dynamic>) :Dynamic
    {
        return _platform.callNative(funcName, params);
    }

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
