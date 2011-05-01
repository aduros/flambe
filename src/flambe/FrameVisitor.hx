package flambe;

import flambe.Entity;
import flambe.Component;
import flambe.Visitor;
import flambe.platform.DrawingContext;
import flambe.animation.Property;

import flambe.display.Transform;
import flambe.display.Sprite;

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
        var n1 = sprite.alpha.get();

        if (sprite.visible.get() && n1 > 0) {
            ++_spriteDepth;

            _drawCtx.save();

            if (n1 < 1) {
                _drawCtx.multiplyAlpha(n1);
            }

            var transform = entity.get(Transform);
            n1 = transform.x.get();
            var n2 = transform.y.get();
            if (n1 != 0 || n2 != 0) {
                _drawCtx.translate(n1, n2);
            }

            n1 = transform.rotation.get();
            if (n1 != 0) {
                _drawCtx.rotate(n1);
            }

            n1 = transform.scaleX.get();
            n2 = transform.scaleY.get();
            if (n1 != 1 || n2 != 1) {
                _drawCtx.scale(n1, n2);
            }

            n1 = sprite.anchorX.get();
            n2 = sprite.anchorY.get();
            if (n1 != 0 || n2 != 0) {
                _drawCtx.translate(-n1, -n2);
            }

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
