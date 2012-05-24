//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe;

import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.display.Stage;
import flambe.input.Keyboard;
import flambe.input.Pointer;
import flambe.platform.AppDriver;
import flambe.storage.Storage;
import flambe.util.Logger;
import flambe.util.Promise;
import flambe.util.Signal1;

#if (!flash && !html)
#error "Platform not supported!"
#end

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
            _driver.init();
            _calledInit = true;
        }
    }

    // A bunch of short-hands to driver functions

    inline public static function loadAssetPack (manifest :Manifest) :Promise<AssetPack>
    {
        return _driver.loadAssetPack(manifest);
    }

    inline public static function callNative (funcName :String, ?params :Array<Dynamic>) :Dynamic
    {
        return _driver.callNative(funcName, params);
    }

    inline public static function logger (tag :String) :Logger
    {
        return new Logger(_driver.createLogHandler(tag));
    }

    inline private static function getStage () :Stage
    {
        return _driver.stage;
    }

    inline private static function getStorage () :Storage
    {
        return _driver.storage;
    }

    inline private static function getPointer () :Pointer
    {
        return _driver.pointer;
    }

    inline private static function getKeyboard () :Keyboard
    {
        return _driver.keyboard;
    }

    inline private static function getLocale () :String
    {
        return _driver.locale;
    }

    private static var _driver =
#if flash
        flambe.platform.flash.FlashAppDriver.instance;
#elseif html
        flambe.platform.html.HtmlAppDriver.instance;
#end

    private static var _calledInit = false;
}
