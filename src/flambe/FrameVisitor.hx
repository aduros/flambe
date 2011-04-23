package flambe;

import flambe.Entity;
import flambe.Component;
import flambe.Visitor;
import flambe.platform.DrawingContext;
import flambe.animation.Property;

import flambe.display.Transform;
import flambe.display.Sprite;

using flambe.display.Transform;

class FrameVisitor
    implements Visitor
{
    public function new (drawCtx :DrawingContext)
    {
        _drawCtx = drawCtx;
    }

    public function init (dt :Int)
    {
        _dt = dt;
        _spriteDepth = 0;
    }

    public function enterEntity (entity :Entity)
    {
    }

    public function leaveEntity (entity :Entity)
    {
        if (_spriteDepth > 0) {
            --_spriteDepth;
            _drawCtx.restore();
        }

        if (entity == _invisibleEntity) {
            _invisibleEntity = null;
        }
    }

    public function acceptComponent (comp :Component)
    {
        comp.update(_dt);
    }

    public function acceptSprite (sprite :Sprite)
    {
        if (_invisibleEntity != null) {
            // We're under an invisible entity
            return;
        }

        var entity = sprite.owner;
        var alpha = sprite.alpha.get();

        if (sprite.visible.get() && alpha > 0) {
            ++_spriteDepth;

            var transform = entity.get(Transform);
            _drawCtx.save();
            _drawCtx.translate(transform.x.get(), transform.y.get());
            _drawCtx.rotate(transform.rotation.get());
            _drawCtx.scale(transform.scaleX.get(), transform.scaleY.get());
            _drawCtx.multiplyAlpha(alpha);
            sprite.draw(_drawCtx);

        } else {
            _invisibleEntity = entity;
        }
    }

    private var _drawCtx :DrawingContext;
    private var _invisibleEntity :Entity;
    private var _spriteDepth :Int;
    private var _dt :Int;
}
