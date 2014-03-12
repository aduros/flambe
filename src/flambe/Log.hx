//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe;

import flambe.util.PackageLog;

/**
 * Flambe's internal logger. Games should use their own by calling `System.createLogger()` or
 * extending `PackageLog`.
 */
class Log extends PackageLog {}
