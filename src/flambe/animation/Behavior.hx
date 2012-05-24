//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.animation;

interface Behavior
{
    function update (dt :Float) :Float;
    function isComplete () :Bool;
}
