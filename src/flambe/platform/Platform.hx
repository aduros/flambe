//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.display.Stage;
import flambe.display.Texture;
import flambe.Entity;
import flambe.input.Keyboard;
import flambe.input.Mouse;
import flambe.input.Pointer;
import flambe.input.Touch;
import flambe.storage.Storage;
import flambe.util.Logger;
import flambe.util.Promise;
import flambe.web.Web;

interface Platform
{
    function init () :Void;

    function getStage () :Stage;
    function getStorage () :Storage;
    function getPointer () :Pointer;
    function getMouse () :Mouse;
    function getTouch () :Touch;
    function getKeyboard () :Keyboard;
    function getWeb () :Web;

    function getLocale () :String;

    function loadAssetPack (manifest :Manifest) :Promise<AssetPack>;

    function callNative (funcName :String, params :Array<Dynamic>) :Dynamic;

    function createLogHandler (tag :String) :LogHandler;

    function getTime () :Float;
}
