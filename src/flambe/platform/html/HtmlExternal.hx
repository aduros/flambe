//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Browser;

import flambe.subsystem.ExternalSystem;

class HtmlExternal
    implements ExternalSystem
{
    public var supported (get, null) :Bool;

    public function new ()
    {
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

        var object = Browser.window;
        var method :Dynamic = object;
        for (fieldName in name.split(".")) {
            object = method;
            method = Reflect.field(object, fieldName);
        }
        return Reflect.callMethod(object, method, params);
    }

    public function bind (name :String, fn :Dynamic)
    {
        Reflect.setField(Browser.window, name, fn);
    }

    public function alert (message:String) :Void 
    {
        untyped __js__("alert")(message);
    }

    public function prompt (message:String, ?defaultValue:String) :String 
    {
        return untyped __js__("prompt")(message, defaultValue);
    }

    public function confirm (message:String) :Bool 
    {
        return untyped __js__("confirm")(message);
    }
}
