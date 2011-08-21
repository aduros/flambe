//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.macro;

#if macro
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.DefaultJSGenerator;
#end

// Tweaks the default JS generator to not use global variables
@:macro
class BrowserJSGenerator extends DefaultJSGenerator
{
    public function new (api)
    {
        super(api);
    }

    override public function generate ()
    {
        print("(function(){"); // Tweak

		print("var $estr = function() { return js.Boot.__string_rec(this,''); }"); // Tweak
		newline();
		for( t in api.types )
			genType(t);
		print("var $_ = {}"); // Tweak
		newline();
		print("js.Boot.__res = {}");
		newline();
		if( Context.defined("debug") ) {
			DefaultJSGenerator.fprint("%(api.stackVar) = []");
			newline();
			DefaultJSGenerator.fprint("%(api.excVar) = []");
			newline();
		}
		print("js.Boot.__init()");
		newline();
		for( e in inits ) {
			genExpr(e);
			newline();
		}
		for( s in statics ) {
			genStaticValue(s.c,s.f);
			newline();
		}
		if( api.main != null ) {
			genExpr(api.main);
			newline();
		}

        print("})();"); // Tweak

		var file = neko.io.File.write(api.outputFile, true);
		file.writeString(buf.toString());
		file.close();
    }

    // Tweaks to DefaultJSGenerator to not pollute the global namespace
    override private function genPackage (p :Array<String>)
    {
		var full = null;
		for( x in p ) {
			var prev = full;
			if( full == null ) full = x else full += "." + x;
			if( packages.exists(full) )
				continue;
			packages.set(full, true);
			if( prev == null )
                DefaultJSGenerator.fprint("var %x = {}"); // Tweak
			else {
				var p = prev + field(x);
				DefaultJSGenerator.fprint("%p = {}"); // Tweak
			}
			newline();
		}
    }

    public static function use ()
    {
        Compiler.setCustomJSGenerator(function (api) new BrowserJSGenerator(api).generate());
        return null;
    }
}
