//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.display.Texture;
import flambe.Entity;
import flambe.input.Keyboard;
import flambe.input.Pointer;
import flambe.util.Promise;

interface AppDriver
{
    var stage (getStage, null) :Stage;

    var storage (getStorage, null) :Storage;

    var pointer (getPointer, null) :Pointer;

    var keyboard (getKeyboard, null) :Keyboard;

    /**
     * Gets the RFC 4646 language tag of the environment. For example, "en-US", "pt", or null if the
     * locale is unknown.
     */
    var locale (getLocale, null) :String;

    function loadAssetPack (manifest :Manifest) :Promise<AssetPack>;

    function callNative (funcName :String, params :Array<Dynamic>) :Dynamic;
}
