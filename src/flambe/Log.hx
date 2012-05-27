//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe;

import flambe.util.Logger;

class Log
{
#if server
    public static var log = flambe.server.Node.logger("flambe");
#else
    public static var log = System.logger("flambe");
#end
}
