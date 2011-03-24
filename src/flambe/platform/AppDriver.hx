package flambe.platform;

import flambe.Entity;
import flambe.display.Texture;

interface AppDriver
{
    function init (root :Entity) :Void;

    function createTexture (assetName :String) :Texture;
}
