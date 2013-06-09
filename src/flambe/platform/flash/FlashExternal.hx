//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.external.ExternalInterface;

import flambe.subsystem.ExternalSystem;

class FlashExternal
    implements ExternalSystem
{
    public var supported (get, null) :Bool;

    public function new ()
    {
        ExternalInterface.marshallExceptions = true;
    }

    public static function shouldUse () :Bool
    {
        return ExternalInterface.available;
    }

    public function get_supported ()
    {
        return true;
    }

    public function call (name :String, ?params :Array<Dynamic>) :Dynamic
    {
        if (params == null) {
            params = [];
        }
        return Reflect.callMethod(null, ExternalInterface.call, [cast name].concat(params));
    }

    public function bind (name :String, fn :Dynamic)
    {
        ExternalInterface.addCallback(name, fn);
        ExternalInterface.call("$flambe_expose", name,
            (fn != null) ? ExternalInterface.objectID : null);
    }
}
