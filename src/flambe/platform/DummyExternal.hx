//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.subsystem.ExternalSystem;

class DummyExternal
    implements ExternalSystem
{
    public var supported (get, null) :Bool;

    public function new ()
    {
    }

    public function get_supported ()
    {
        return false;
    }

    public function call (name :String, ?params :Array<Dynamic>) :Dynamic
    {
        return null;
    }

    public function bind (name :String, fn :Dynamic)
    {
    }
}
