//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

import flambe.animation.AnimatedFloat;
import flambe.math.FMath;

using flambe.util.Arrays;

/**
 * A sprite that displays a particle system.
 */
class EmitterSprite extends Sprite
{
    public var texture :Texture;

    public var maxParticles (get_maxParticles, set_maxParticles) :Int;

    public var emitX (default, null) :AnimatedFloat;
    public var emitXVariance (default, null) :AnimatedFloat;

    public var emitY (default, null) :AnimatedFloat;
    public var emitYVariance (default, null) :AnimatedFloat;

    public var alphaStart (default, null) :AnimatedFloat;
    public var alphaStartVariance (default, null) :AnimatedFloat;

    public var alphaEnd (default, null) :AnimatedFloat;
    public var alphaEndVariance (default, null) :AnimatedFloat;

    public var angle (default, null) :AnimatedFloat;
    public var angleVariance (default, null) :AnimatedFloat;

    // TODO(bruno): Implement!
    public var duration (default, null) :AnimatedFloat;

    public var gravityX (default, null) :AnimatedFloat;
    public var gravityY (default, null) :AnimatedFloat;

    // TODO(bruno): Implement!
    public var maxRadius (default, null) :AnimatedFloat;
    public var maxRadiusVariance (default, null) :AnimatedFloat;

    public var lifespanVariance (default, null) :AnimatedFloat;
    public var lifespan (default, null) :AnimatedFloat;

    // TODO(bruno): Implement!
    public var rotatePerSecond (default, null) :AnimatedFloat;
    public var rotatePerSecondVariance (default, null) :AnimatedFloat;

    public var rotationStart (default, null) :AnimatedFloat;
    public var rotationStartVariance (default, null) :AnimatedFloat;

    public var rotationEnd (default, null) :AnimatedFloat;
    public var rotationEndVariance (default, null) :AnimatedFloat;

    public var sizeStart (default, null) :AnimatedFloat;
    public var sizeStartVariance (default, null) :AnimatedFloat;

    public var sizeEnd (default, null) :AnimatedFloat;
    public var sizeEndVariance (default, null) :AnimatedFloat;

    public var speed (default, null) :AnimatedFloat;
    public var speedVariance (default, null) :AnimatedFloat;

    // TODO(bruno): Implement!
    public var radialAccel (default, null) :AnimatedFloat;
    public var radialAccelVariance (default, null) :AnimatedFloat;

    // TODO(bruno): Implement!
    public var tangentialAccel (default, null) :AnimatedFloat;
    public var tangentialAccelVariance (default, null) :AnimatedFloat;

    public function new (config :EmitterConfig)
    {
        super();

        texture = config.texture;
        blendMode = config.blendMode;

        alphaEnd = new AnimatedFloat(config.alphaEnd);
        alphaEndVariance = new AnimatedFloat(config.alphaEndVariance);
        alphaStart = new AnimatedFloat(config.alphaStart);
        alphaStartVariance = new AnimatedFloat(config.alphaStartVariance);
        angle = new AnimatedFloat(config.angle);
        angleVariance = new AnimatedFloat(config.angleVariance);
        duration = new AnimatedFloat(config.duration);
        emitXVariance = new AnimatedFloat(config.emitXVariance);
        emitYVariance = new AnimatedFloat(config.emitYVariance);
        gravityX = new AnimatedFloat(config.gravityX);
        gravityY = new AnimatedFloat(config.gravityY);
        lifespan = new AnimatedFloat(config.lifespan);
        lifespanVariance = new AnimatedFloat(config.lifespanVariance);
        maxRadius = new AnimatedFloat(config.maxRadius);
        maxRadiusVariance = new AnimatedFloat(config.maxRadiusVariance);
        radialAccel = new AnimatedFloat(config.radialAccel);
        radialAccelVariance = new AnimatedFloat(config.radialAccelVariance);
        rotatePerSecond = new AnimatedFloat(config.rotatePerSecond);
        rotatePerSecondVariance = new AnimatedFloat(config.rotatePerSecondVariance);
        rotationEnd = new AnimatedFloat(config.rotationEnd);
        rotationEndVariance = new AnimatedFloat(config.rotationEndVariance);
        rotationStart = new AnimatedFloat(config.rotationStart);
        rotationStartVariance = new AnimatedFloat(config.rotationStartVariance);
        sizeEnd = new AnimatedFloat(config.sizeEnd);
        sizeEndVariance = new AnimatedFloat(config.sizeEndVariance);
        sizeStart = new AnimatedFloat(config.sizeStart);
        sizeStartVariance = new AnimatedFloat(config.sizeStartVariance);
        speed = new AnimatedFloat(config.speed);
        speedVariance = new AnimatedFloat(config.speedVariance);
        tangentialAccel = new AnimatedFloat(config.tangentialAccel);
        tangentialAccelVariance = new AnimatedFloat(config.tangentialAccelVariance);

        emitX = new AnimatedFloat(0);
        emitY = new AnimatedFloat(0);

        _particles = Arrays.create(config.maxParticles);
        var ii = 0, ll = _particles.length;
        while (ii < ll) {
            _particles[ii] = new Particle();
            ++ii;
        }
    }

    override public function onUpdate (dt :Float)
    {
        super.onUpdate(dt);

        alphaEnd.update(dt);
        alphaEndVariance.update(dt);
        alphaStart.update(dt);
        alphaStartVariance.update(dt);
        angle.update(dt);
        angleVariance.update(dt);
        duration.update(dt);
        gravityX.update(dt);
        gravityY.update(dt);
        lifespan.update(dt);
        lifespanVariance.update(dt);
        maxRadius.update(dt);
        maxRadiusVariance.update(dt);
        radialAccel.update(dt);
        radialAccelVariance.update(dt);
        rotatePerSecond.update(dt);
        rotatePerSecondVariance.update(dt);
        rotationEnd.update(dt);
        rotationEndVariance.update(dt);
        rotationStart.update(dt);
        rotationStartVariance.update(dt);
        speed.update(dt);
        speedVariance.update(dt);
        tangentialAccel.update(dt);
        tangentialAccelVariance.update(dt);
        emitXVariance.update(dt);
        emitYVariance.update(dt);

        // Update existing particles
        var ii = 0;
        while (ii < _numParticles) {
            var particle = _particles[ii];
            if (particle.life > dt) {
                particle.x += particle.velX * dt;
                particle.y += particle.velY * dt;

                particle.velX += gravityX._ * dt;
                particle.velY += gravityY._ * dt;

                particle.scale += particle.velScale * dt;
                particle.rotation += particle.velRotation * dt;
                particle.alpha += particle.velAlpha * dt;

                particle.life -= dt;
                ++ii;

            } else {
                // Kill it, and swap it with the last living particle, so that alive particles are
                // packed to the front of the pool
                --_numParticles;
                if (ii != _numParticles) {
                    _particles[ii] = _particles[_numParticles];
                    _particles[_numParticles] = particle;
                }
            }
        }

        // Emit new particles
        var emitDelay = lifespan._ / _particles.length;
        _emitElapsed += dt;
        while (_emitElapsed >= emitDelay) {
            if (_numParticles < _particles.length) {
                var particle = _particles[_numParticles];
                if (initParticle(particle)) {
                    ++_numParticles;
                }
            }
            _emitElapsed -= emitDelay;
        }
    }

    override public function draw (g :Graphics)
    {
        var offsetX = -texture.width/2;
        var offsetY = -texture.height/2;

        var ii = 0, ll = _numParticles;
        while (ii < ll) {
            var particle = _particles[ii];
            g.save();
            g.translate(particle.x, particle.y);
            if (particle.alpha < 1) {
                g.multiplyAlpha(particle.alpha);
            }
            if (particle.rotation != 0) {
                g.rotate(particle.rotation);
            }
            if (particle.scale != 1) {
                g.scale(particle.scale, particle.scale);
            }
            g.drawImage(texture, offsetX, offsetY);
            g.restore();

            ++ii;
        }
    }

    private function initParticle (particle :Particle)
    {
        particle.life = random(lifespan._, lifespanVariance._);
        if (particle.life <= 0) {
            return false; // Dead on arrival
        }

        particle.x = random(emitX._, emitXVariance._);
        particle.y = random(emitY._, emitYVariance._);

        var angle = FMath.toRadians(random(angle._, angleVariance._));
        var speed = random(speed._, speedVariance._);
        particle.velX = speed * Math.cos(angle);
        particle.velY = speed * Math.sin(angle);

        var width = texture.width;
        var scaleStart = random(sizeStart._, sizeStartVariance._) / width;
        var scaleEnd = random(sizeEnd._, sizeEndVariance._) / width;
        particle.scale = scaleStart;
        particle.velScale = (scaleEnd-scaleStart) / particle.life;

        var rotationStart = random(rotationStart._, rotationStartVariance._);
        var rotationEnd = random(rotationEnd._, rotationEndVariance._);
        particle.rotation = rotationStart;
        particle.velRotation = (rotationEnd-rotationStart) / particle.life;

        var alphaStart = random(alphaStart._, alphaStartVariance._);
        var alphaEnd = random(alphaEnd._, alphaEndVariance._);
        particle.alpha = alphaStart;
        particle.velAlpha = (alphaEnd-alphaStart) / particle.life;

        return true;
    }

    inline private function get_maxParticles () :Int
    {
        return _particles.length;
    }

    private function set_maxParticles (maxParticles :Int) :Int
    {
        // Grow the pool
        var oldLength = _particles.length;
        _particles.resize(maxParticles);
        while (oldLength < maxParticles) {
            _particles[oldLength] = new Particle();
            ++oldLength;
        }

        if (_numParticles > maxParticles) {
            _numParticles = maxParticles;
        }

        return maxParticles;
    }

    private static function random (base :Float, variance :Float)
    {
        if (variance != 0) {
            base += variance * (2*Math.random()-1);
        }
        return base;
    }

    // The particle pool
    private var _particles :Array<Particle>;

    // Number of currently alive particles
    private var _numParticles :Int = 0;

    // Time passed since the last emission
    private var _emitElapsed :Float = 0;
}

private class Particle
{
    public var x :Float = 0;
    public var velX :Float = 0;

    public var y :Float = 0;
    public var velY :Float = 0;

    public var scale :Float = 0;
    public var velScale :Float = 0;

    public var rotation :Float = 0;
    public var velRotation :Float = 0;

    public var alpha :Float = 0;
    public var velAlpha :Float = 0;

    public var life :Float = 0;

    public function new () {}
}
