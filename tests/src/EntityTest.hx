//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

import haxe.unit.TestCase;

import flambe.Component;
import flambe.Entity;
import flambe.Visitor;

class EntityTest extends TestCase
{
    public function testHierarchy ()
    {
        var parent = new Entity();
        var comp = new TestComponent();

        assertEquals(parent.add(comp), parent);

        assertTrue(parent.has(TestComponent));
        assertEquals(parent.get(TestComponent), comp);

        comp.dispose();
        assertFalse(parent.has(TestComponent));
        assertEquals(parent.get(TestComponent), null);

        comp = new TestComponent();
        var child = new Entity().add(comp);

        parent.addChild(child);
        assertEquals(child.parent, parent);

        parent.dispose();
        assertEquals(child.parent, null);

        child.remove(comp);
        assertFalse(child.has(TestComponent));
    }
}

class TestComponent extends Component
{
    public function new () { }
}
