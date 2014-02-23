//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.display.Texture;
import flambe.subsystem.*;
import flambe.util.Logger;
import flambe.util.Promise;

interface Platform
{
    function init () :Void;

    function getExternal () :ExternalSystem;
    function getKeyboard () :KeyboardSystem;
    function getMotion() :MotionSystem;
    function getMouse () :MouseSystem;
    function getPointer () :PointerSystem;
    function getRenderer () :InternalRenderer<Dynamic>;
    function getStage () :StageSystem;
    function getStorage () :StorageSystem;
    function getTouch () :TouchSystem;
    function getWeb () :WebSystem;

    function createLogHandler (tag :String) :LogHandler;
    function loadAssetPack (manifest :Manifest) :Promise<AssetPack>;
    function getCatapultClient () :CatapultClient;

    function getLocale () :String;
    function getTime () :Float;
}
