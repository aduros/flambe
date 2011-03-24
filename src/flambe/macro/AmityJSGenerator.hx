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
        super.generate();
    }

    public static function use ()
    {
        /*Compiler.removeField("js.Lib", "document", true);*/
        /*Compiler.removeField("js.Lib", "window", true);*/
        /*Compiler.removeField("js.Lib", "isOpera", true);*/
        /*Compiler.removeField("js.Lib", "isIE", true);*/
        Compiler.setCustomJSGenerator(function (api) new AmityJSGenerator(api).generate());
        return null; // What's the correct haxe flag to avoid this? Not --macro
    }
}
