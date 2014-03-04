//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

import haxe.PosInfos;

import js.Browser;

import flambe.animation.Ease;
import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.display.FillSprite;
import flambe.display.ImageSprite;
import flambe.Entity;
import flambe.System;

class SeleniumMain
{
    private static function onSuccess (pack :AssetPack)
    {
        var background = new Entity()
            .add(new FillSprite(0x00ff00, System.stage.width, System.stage.height));
        System.root.addChild(background);

        // Test texture loading
        var texture = pack.getTexture("texture");
        assert(texture.width == 128);
        assert(texture.height == 118);
        System.root.addChild(new Entity().add(
            new ImageSprite(texture).setXY(50, 100)));

        // Test sound loading
        var sound = pack.getSound("sound");
        // assert(sound.duration == 0 || sound.duration-3.5524 < 0.0001);
        sound.play(0.25);

        // Test file loading
        assert(pack.getFile("file.txt").toString() == "Hello world\n");
    }

    private static function main ()
    {
        catchErrors(function () {
            System.init();

            // Some basic sanity checking
            assert(System.stage.width > 0 && System.stage.height > 0);

            // Test storage
            System.storage.set("$flambe_tmp", "foobar");
            assert(System.storage.get("$flambe_tmp") == "foobar");

            // Test asset pack loading
            var loader = System.loadAssetPack(Manifest.fromAssets("bootstrap"));
            loader.error.connect(function (error) catchErrors(function () {
                fail(error);
            }));
            loader.get(function (pack) catchErrors(function () {
                onSuccess(pack);
                setStatus("OK"); // All done!
            }));
        });
    }

    private static function assert (condition :Bool, ?pos :PosInfos)
    {
        if (!condition) {
            fail("Assert", pos);
        }
    }

    private static function fail (message :String, ?pos :PosInfos)
    {
        // Throw an error that should be caught by catchErrors
        throw message+" ("+pos.fileName+":"+pos.lineNumber+")";
    }

    private static function catchErrors (fn :Void -> Void)
    {
        try {
            fn();
        } catch (error :Dynamic) {
            setStatus("FAIL: " + error);
        }
    }

    private static function setStatus (status :String)
    {
        // Set the test status so driver.py can scoop it up
        Reflect.setField(Browser.window, "$flambe_selenium_status", status);
    }
}
