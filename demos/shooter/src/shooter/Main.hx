//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package shooter;

import flambe.asset.Manifest;
import flambe.System;

class Main
{
    private static function main ()
    {
        System.init();
        var loader = System.loadAssetPack(Manifest.build("bootstrap"));
        loader.success.connect(function (pack) {
            ShooterCtx.pack = pack;
            System.root.add(new Game());
        });
        loader.error.connect(function (message) {
            trace("Loading error: " + message);
        });
        loader.progressChanged.connect(function () {
            trace("Loading progress... " + loader.progress + " of " + loader.total);
        });
    }
}
