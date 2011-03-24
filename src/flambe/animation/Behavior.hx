package flambe.animation;

interface Behavior<A>
{
    function update (dt :Int) :A;
    function isComplete () :Bool;
}
