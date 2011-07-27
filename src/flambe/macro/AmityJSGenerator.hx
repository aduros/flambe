//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.macro;

#if macro
import haxe.macro.Compiler;
import haxe.macro.DefaultJSGenerator;
#end

@:macro
class AmityJSGenerator extends DefaultJSGenerator
{
    public function new (api)
    {
        super(api);
    }

    override public function generate ()
    {
        // document and window (even if they're undefined) must exist for haXe's generated JS to run
        // in Amity. A better solution in the future will be to scrub all code that assumes a web
        // browser from haXe's JS library.
        print("var document,window;");
        super.generate();
    }

    public static function use ()
    {
        Compiler.setCustomJSGenerator(function (api) new AmityJSGenerator(api).generate());
        return null; // What's the correct haxe flag to avoid this? Not --macro
    }
}
