//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe;

import flambe.util.Logger;

class Log
{
    // public static var log = System.logger("flambe");

    // Normally you'd just be able to write the above, but since this logger is used internally, we
    // avoid System here due to static initializer dependency issues.
    public static var log = new Logger(
#if flash
        flambe.platform.flash.FlashAppDriver.instance
#else
        flambe.platform.html.HtmlAppDriver.instance
#end
        .createLogHandler("flambe"));
}
