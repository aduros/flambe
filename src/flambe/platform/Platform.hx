//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.Entity;
import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.subsystem.StageSystem;
import flambe.display.Texture;
import flambe.subsystem.ExternalSystem;
import flambe.subsystem.KeyboardSystem;
import flambe.subsystem.MouseSystem;
import flambe.subsystem.PointerSystem;
import flambe.subsystem.TouchSystem;
import flambe.subsystem.MotionSystem;
import flambe.subsystem.StorageSystem;
import flambe.util.Logger;
import flambe.util.Promise;
import flambe.subsystem.WebSystem;

interface Platform
{
    function init () :Void;

    function getExternal () :ExternalSystem;
    function getKeyboard () :KeyboardSystem;
    function getMotion() :MotionSystem;
    function getMouse () :MouseSystem;
    function getPointer () :PointerSystem;
    function getStage () :StageSystem;
    function getStorage () :StorageSystem;
    function getTouch () :TouchSystem;
    function getWeb () :WebSystem;

    function getRenderer () :Renderer;

    function createLogHandler (tag :String) :LogHandler;
    function loadAssetPack (manifest :Manifest) :Promise<AssetPack>;

    function getLocale () :String;
    function getTime () :Float;
}
