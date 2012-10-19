//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;

using flambe.util.Strings;

/**
 * Stupid-simple text localization.
 */
class MessageBundle
{
    public var config (default, null) :Config;

    /**
     * Emitted when a translation is requested that this bundle doesn't provide.
     */
    public var missingTranslation :Signal1<String>;

    public function new (config :Config)
    {
        this.config = config;
        missingTranslation = new Signal1();
    }

    inline public static function parse (text :String) :MessageBundle
    {
        return new MessageBundle(Config.parse(text));
    }

    /**
     * Fetch a translation from the config, and substitute in params with Strings.substitute. If
     * the path doesn't exist in the config, missingTranslation is emitted and the original path is
     * returned.
     */
    public function get (path :String, ?params :Array<Dynamic>) :String
    {
        var value = config.get(path);
        if (value == null) {
            Log.warn("Requested a missing translation from bundle", ["path", path]);
            missingTranslation.emit(path);
            return path; // Return the best we can
        }

        return (params != null) ? value.substitute(params) : value;
    }
}
