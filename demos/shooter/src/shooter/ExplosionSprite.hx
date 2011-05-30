package shooter;

import flambe.display.Sprite;
import flambe.display.Texture;
import flambe.platform.DrawingContext;

// TODO(bruno): A more generic and data-driven way of doing animated sprites will be ideal later
class ExplosionSprite extends Sprite
{
    public static inline var SIZE = 40;
    public static inline var MS_PER_FRAME = 100;

    public function new ()
    {
        super();
        _texture = ShooterCtx.pack.createTexture("explosion.png");
        _elapsed = 0;
        centerAnchor();
    }

    override public function draw (ctx :DrawingContext)
    {
        ctx.drawSubImage(_texture, 0, 0, SIZE*Std.int(_elapsed/MS_PER_FRAME), 0, SIZE, SIZE);
    }

    override public function onUpdate (dt)
    {
        super.onUpdate(dt);
        _elapsed += dt;
        if (_elapsed > 8*MS_PER_FRAME) {
            owner.dispose();
        }
    }

    override public function getNaturalWidth () :Float
    {
        return SIZE;
    }

    override public function getNaturalHeight () :Float
    {
        return SIZE;
    }

    private var _texture :Texture;
    private var _elapsed :Int;
}
