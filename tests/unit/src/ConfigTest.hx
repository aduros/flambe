//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

import haxe.unit.TestCase;

import flambe.util.Config;
import flambe.util.MessageBundle;

using flambe.util.Maps;

class ConfigTest extends TestCase
{
    public function testConfigs ()
    {
        var run = function (config :Config) {
            var section = config.mainSection;
            assertEquals(section.get("foo"), "trim me");
            assertEquals(section.getInt("someInt"), 69);
            assertEquals(section.getFloat("someFloat"), 69.69);
            assertEquals(section.getBool("someBool"), true);
            assertEquals(section.getBool("someInt"), true);

            assertEquals(config.get("extras.password"), "   whitespace ");

            section = config.section("extras");
            assertEquals(section.get("password"), "   whitespace ");
            assertEquals(section.getString("username", "Nope"), "Nope");
        };

        var config = Config.parse(TEST_FILE);
        run(config);
        run(Config.parse(config.toString())); // Tests toString
    }

    public function testMessageBundles ()
    {
        var msgs = MessageBundle.parse(TEST_FILE);

        assertTrue(msgs.config != null);

        var fired = null;
        msgs.missingTranslation.connect(function (path) fired = path);

        assertEquals(msgs.get("player.you_win", ["John", 555]),
            "Congrats John, you got a score of 555");
        assertEquals(fired, null);

        assertEquals(msgs.get("player.missing"), "player.missing");
        assertEquals(fired, "player.missing");
    }

    private static var TEST_FILE = "
        ; This is a comment
        # So is this
        foo =    trim me
        someInt = 69
        someFloat = 69.69
        someBool = true

        [extras]
        password = \"   whitespace \"

        [player]
        you_win = Congrats {0}, you got a score of {1}
    ";
}
