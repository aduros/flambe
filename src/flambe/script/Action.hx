//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.script;

import flambe.Entity;

interface Action
{
    function update (dt :Float, actor :Entity) :Bool;
}
