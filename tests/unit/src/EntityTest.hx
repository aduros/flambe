//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

import haxe.unit.TestCase;

import flambe.Component;
import flambe.Entity;

class EntityTest extends TestCase
{
    public function testHierarchy ()
    {
        var parent = new Entity();
        var comp = new TestComponent();

        assertEquals(parent.add(comp), parent);
        assertEquals(comp.owner, parent);
        assertEquals(comp.next, null);
        assertTrue(parent.has(TestComponent));
        assertEquals(parent.get(TestComponent), comp);
        assertEquals(parent.firstComponent, comp);

        assertTrue(parent.has(EntityTest.TestComponent));
        assertEquals(parent.get(EntityTest.TestComponent), comp);

        comp.dispose();
        assertFalse(parent.has(TestComponent));
        assertEquals(parent.get(TestComponent), null);

        comp = new TestComponent();
        var child = new Entity().add(comp);

        parent.addChild(child);
        assertEquals(child.parent, parent);

        // Transfer component to another entity
        parent.add(comp);
        assertEquals(comp.owner, parent);
        assertFalse(child.has(TestComponent));
        assertEquals(child.firstComponent, null);
        assertTrue(parent.has(TestComponent));
        assertEquals(parent.firstComponent, comp);

        child.dispose();
        assertEquals(child.parent, null);

        parent.remove(comp);
        assertFalse(child.has(TestComponent));
    }
}

class TestComponent extends Component
{
    public function new () { }
}
