//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

import haxe.unit.TestCase;

using flambe.util.Strings;

class StringTest extends TestCase
{
    public function testStrings ()
    {
        assertEquals("foo.png".getFileExtension(), "png");
        assertEquals(".foo.png".getFileExtension(), "png");
        assertEquals("foo".getFileExtension(), null);
        assertEquals(".foo".getFileExtension(), null);

        assertEquals("{1} is {0}".substitute(["love", "what"]), "what is love");
    }
}
