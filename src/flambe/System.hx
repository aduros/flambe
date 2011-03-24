package flambe;

import flambe.display.MouseEvent;
import flambe.display.Sprite;
import flambe.platform.AppDriver;
import flambe.util.Signal1;

class System
{
    public static var root (default, null) :Entity;
    public static var driver (default, null) :AppDriver;

    public static var mouseDown (default, null) :Signal1<MouseEvent>;
    
    public static function init ()
    {
        root = new Entity();
        mouseDown = new Signal1(onMouseDown);

#if flash
        driver = new flambe.platform.flash.FlashAppDriver();
#elseif amity
        driver = new flambe.platform.amity.AmityAppDriver();
#else
#error "Platform not supported!"
#end
        driver.init(root);
    }

    private static function onMouseDown (event :MouseEvent)
    {
        for (sprite in Sprite.INTERACTIVE_SPRITES) {
            if (sprite.contains(event.viewX, event.viewY)) {
                sprite.mouseDown.emit(event);
                return;
            }
        }
    }
}

class InputVisitor
    implements Visitor
{
    public function new () { }

    public function init (event :MouseEvent)
    {
        _event = event;
    }

    public function enterEntity (e :Entity) { }
    public function leaveEntity (e :Entity) { }
    public function acceptComponent (t :Component) { }

    public function acceptSprite (sprite :Sprite)
    {
        if (sprite.contains(_event.viewX, _event.viewY)) {
            sprite.mouseDown.emit(_event);
        }
    }

    private var _event :MouseEvent;
}
