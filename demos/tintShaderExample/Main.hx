package tintShaderExample;

import flambe.Entity;
import flambe.System;
import flambe.asset.Manifest;
import flambe.asset.AssetPack;

import flambe.display.Font;
import flambe.display.FillSprite;
import flambe.display.TextSprite;
import flambe.display.ImageSprite;
import flambe.display.MaterialSprite;
import flambe.display.Material;

import flambe.platform.Effect;
import flambe.platform.shader.DefaultEffect;
import tintShaderExample.TintEffect;

// Main Class
// Description: Entry point
class Main
{
    // ATTRIBUTES ---------------
    // Private
    // Assets
    private static var assetPack:AssetPack;
    private static var gameFont:Font;

    // Demo
    private static var demoScreen:Entity;
    private static var demoText:TextSprite;

    // METHODS ------------------
    // MAIN
    private static function main()
    {
        // Wind up all platform-specific
        System.init();

        // Load up the compiled pack in the assets directory named "bootstrap"
        var manifest = Manifest.fromAssets("bootstrap");
        var loader = System.loadAssetPack(manifest);
        loader.get(onSuccess);
    }

    // ON SUCCESS
    private static function onSuccess(pack:AssetPack)
    {
        // Store the asset pack for use later
        assetPack = pack;

        // Grab the font from the asset pack for use later
        gameFont = new Font(assetPack, "bebasNeue48");

        // Add a basic background that will be present on all screens
        var gameBG = new FillSprite(0x033E6B, System.stage.width, System.stage.height);
        System.root.addChild(new Entity().add(gameBG));

        // Demo Screen
        DemoScreen();
    }

    // DEMO SCREEN
    private static function DemoScreen():Void
    {
        // Create the basic entity that will contain demo elements
        demoScreen = new Entity();

        // Create a UI section for displaying the demo title
        var titleSection:Entity = new Entity();
        var titleBG = new FillSprite(0xFF9200, System.stage.width, 50);
        titleSection.add(titleBG);

        demoText = new TextSprite(gameFont, "");
        demoText.text = "Color Tint";
        titleSection.addChild(new Entity().add(demoText));

        demoScreen.addChild(titleSection);

        // Create plane entity and image
        System.renderer.registerEffect("tintEffect", new TintEffect());
        System.renderer.assignFloat4("tintEffect", "tintColor", 1, 0, 0, 1);

        // Create the plane and add it to the middle of the screen
        var plane:Entity = new Entity();

        var planeMaterial = new Material().setEffect("tintEffect");
        plane.add(planeMaterial);

        var planeSprite = new MaterialSprite(assetPack.getTexture("plane"));
        planeSprite.centerAnchor();
        planeSprite.x._ = System.stage.width * 0.5;
        planeSprite.y._ = System.stage.height * 0.5;
        plane.add(planeSprite);

        demoScreen.addChild(plane);

        // Show the demo screen
        System.root.addChild(demoScreen);
    }
}
