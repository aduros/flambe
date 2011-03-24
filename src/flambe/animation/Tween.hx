package flambe.animation;

class Tween
    implements Behavior<Float>
{
    public function new (from :Float, to :Float, duration :Int)
    {
        _from = from;
        _to = to;
        _duration = duration;
        _elapsed = 0;
    }

    public function update (dt :Int) :Float
    {
        _elapsed += dt;

        if (_elapsed >= _duration) {
            return _to;
        } else {
            return _from + (_to - _from) * (_elapsed/_duration);
        }
    }

    public function isComplete () :Bool
    {
        return _elapsed >= _duration;
    }

    private var _from :Float;
    private var _to :Float;
    private var _elapsed :Int;
    private var _duration :Int;
}
