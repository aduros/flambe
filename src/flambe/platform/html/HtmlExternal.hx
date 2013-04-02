//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Browser;

import flambe.external.External;

class HtmlExternal
    implements External
{
    public var supported (get, null) :Bool;

    public function new (target :Dynamic)
    {
      _target = target;
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

        var method = Reflect.field(_target, name);
        return Reflect.callMethod(null, method, params);
    }

    public function bind (name :String, fn :Dynamic)
    {
        Reflect.setField(_target, name, fn);
    }

    private var _target :Dynamic;
}
