//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;

using StringTools;

typedef ConfigSection = Map<String,String>;

/**
 * An INI-like config file parser.
 *
 * ```ini
 * ; This is a comment
 * foo = some value
 * [my section]
 * password = "  quotes are optional, and useful if you want to preserve surrounding spaces  "
 * ```
 */
class Config
{
    public var mainSection (default, null) :ConfigSection;
    public var sections (default, null) :Map<String,ConfigSection>;

    public function new ()
    {
        mainSection = new ConfigSection();
        sections = new Map();
    }

    /** Parse the contents of an INI file. */
    public static function parse (text :String) :Config
    {
        var config = new Config();

        var commentPattern = ~/^\s*;/;
        var sectionPattern = ~/^\s*\[\s*([^\]]*)\s*\]/;
        var pairPattern = ~/^\s*([\w\.\-_]+)\s*=\s*(.*)/;

        var currentSection = config.mainSection;
        for (line in ~/\r\n|\r|\n/g.split(text)) {
            if (commentPattern.match(line)) {
                // Ignore this line

            } else if (sectionPattern.match(line)) {
                var name = sectionPattern.matched(1);
                if (config.sections.exists(name)) {
                    // Handle duplicate sections, should this be allowed?
                    currentSection = config.sections.get(name);
                } else {
                    currentSection = new ConfigSection();
                    config.sections.set(name, currentSection);
                }

            } else if (pairPattern.match(line)) {
                var key = pairPattern.matched(1);
                var value = pairPattern.matched(2);
                var quote = value.fastCodeAt(0);
                if ((quote == "\"".code || quote == "'".code) &&
                        value.fastCodeAt(value.length-1) == quote) {
                    // Trim off quotes
                    value = value.substr(1, value.length-2);
                }
                currentSection.set(key, value
                    // Unescape certain characters
                    .replace("\\n", "\n")
                    .replace("\\r", "\r")
                    .replace("\\t", "\t")
                    .replace("\\'", "\'")
                    .replace("\\\"", "\"")
                    .replace("\\\\", "\\")
                );
            }
        }

        return config;
    }

    /** Shorthand for sections.get(name). */
    inline public function section (name :String) :ConfigSection
    {
        return sections.get(name);
    }

    /**
     * Searches for a value with a full path. A path is a section and key name separated by a dot. A
     * path without a dot is assumed to be in the main section.
     *
     * Eg: get("foo.bar") is the same as section("foo").get("bar");
     */
    public function get (path :String) :String
    {
        var idx = path.indexOf(".");
        if (idx < 0) {
            return mainSection.get(path);
        }

        var section = sections.get(path.substr(0, idx));
        return (section != null) ? section.get(path.substr(idx+1)) : null;
    }

    /** Serialize back to an INI file. */
    public function toString () :String
    {
        // TODO(bruno): Use StringBuf if Flambe is ever ported to hxcpp
        var str = "";
        for (key in mainSection.keys()) {
            str += key + " = \"" + mainSection.get(key) + "\"\n";
        }
        for (name in sections.keys()) {
            str += "[" + name + "]\n";
            var section = sections.get(name);
            for (key in section.keys()) {
                str += key + " = \"" + section.get(key) + "\"\n";
            }
        }
        return str;
    }
}
