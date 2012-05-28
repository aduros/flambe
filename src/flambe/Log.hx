//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe;

import flambe.util.Logger;

/**
 * Flambe's internal logger. Games should use their own by calling System.logger().
 */
class Log
{
#if server
    public static var log = flambe.server.Node.logger("flambe");
#else
    public static var log = System.logger("flambe");
#end
}
