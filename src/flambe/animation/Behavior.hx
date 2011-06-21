//
// Flambe - Rapid game development
// https://github.com/aduros/amity/blob/master/LICENSE.txt

package flambe.animation;

interface Behavior<A>
{
    function update (dt :Int) :A;
    function isComplete () :Bool;
}
