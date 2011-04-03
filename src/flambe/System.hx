package flambe;

import flambe.display.MouseEvent;
import flambe.display.Sprite;
import flambe.platform.AppDriver;
import flambe.util.Signal1;

class System
{
    public static var root (default, null) :Entity;
    public static var driver (default, null) :AppDriver;

    public static var stageWidth (getStageWidth, null) :Int;
    public static var stageHeight (getStageHeight, null) :Int;

    public static function init ()
    {
        root = new Entity();

#if flash
        driver = new flambe.platform.flash.FlashAppDriver();
#elseif amity
        driver = new flambe.platform.amity.AmityAppDriver();
#else
#error "Platform not supported!"
#end
        driver.init(root);
    }

    inline public static function loadAssetPack (url)
    {
        return driver.loadAssetPack(url);
    }

    private static function getStageWidth () :Int
    {
        return driver.getStageWidth();
    }

    private static function getStageHeight () :Int
    {
        return driver.getStageHeight();
    }
}
