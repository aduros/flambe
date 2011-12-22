//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.display.Texture;
import flambe.Entity;
import flambe.util.Promise;

interface AppDriver
{
    function init (root :Entity) :Void;

    function loadAssetPack (manifest :Manifest) :Promise<AssetPack>;

    function getStage () :Stage;
    function getStorage () :Storage;

    /**
     * Gets the RFC 4646 language tag of the environment. For example, "en-US", "pt", or null if the
     * locale is unknown.
     */
    function getLocale () :String;

    function callNative (funcName :String, params :Array<Dynamic>) :Dynamic;
}
