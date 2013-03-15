//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import flambe.util.Logger;

class HtmlLogHandler
    implements LogHandler
{
	#if (nodejs || server)
		//http://www.linuxhowtos.org/Tips%20and%20Tricks/ansi_escape_sequences.htm
		static var RED = '\033[31m';
		static var YELLOW = '\033[33m';
		static var GREEN = '\033[32m';
		static var RESET = '\033[0m';
	#end
    public static function isSupported () :Bool
    {
        return untyped __js__("typeof console") == "object" && console.info != null;
    }

    public function new (tag :String)
    {
        _tagPrefix = tag + ": ";
    }

    public function log (level :LogLevel, message :String)
    {
        message = _tagPrefix + message;

        #if (nodejs || server)
        switch (level) {
			case Info:
				(untyped console).info(GREEN + message + RESET);
			case Warn:
				(untyped console).warn(YELLOW + message + RESET);
			case Error:
				(untyped console).error(RED + message + RESET);
			}
			
        #else
			switch (level) {
			case Info:
				(untyped console).info(message);
			case Warn:
				(untyped console).warn(message);
			case Error:
				(untyped console).error(message);
			}
        #end
        
        
    }

    private var _tagPrefix :String;
}
