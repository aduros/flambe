//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

import haxe.unit.TestCase;

import flambe.util.Promise;
import flambe.util.Signal1;
import flambe.util.Value;

class ReactiveTest extends TestCase
{
    public function testSignals ()
    {
        var signal = new Signal1<Int>();

        var fired = 0;
        var connection = signal.connect(function (n) fired = n);

        signal.emit(1);
        assertEquals(fired, 1);

        fired = 0;
        connection.dispose();
        signal.emit(1);
        assertEquals(fired, 0);

        var count = 0;
        var connection = signal.connect(function (n) count += n).once();
        signal.emit(1);
        signal.emit(1);
        assertEquals(count, 1);

        signal = new Signal1();
        signal.connect(function (n) {
            signal.connect(function (n) fired = n);
        });
        fired = 0;
        signal.emit(1);
        assertEquals(fired, 0);

        signal = new Signal1();
        signal.connect(function (n) fired = 100);
        signal.connect(function (n) fired = 200);
        signal.connect(function (n) fired = 300, true);
        signal.emit(0);
        assertEquals(fired, 200);

        signal = new Signal1();
        var conn2 = null;
        var conn1 = signal.connect(function (n) {
            conn2.dispose();
        });
        conn2 = signal.connect(function (n) {
            fired = 1;
        });
        fired = 0;
        signal.emit(1); // conn2 still fires
        assertEquals(fired, 1);
        fired = 0;
        signal.emit(1); // conn2 doesn't fire
        assertEquals(fired, 0);
    }

    public function testValues ()
    {
        var value = new Value<Int>(1);
        assertEquals(value._, 1);

        var fired = false;
        value.changed.connect(function (_,_) fired = true);
        value.changed.connect(function (newValue, oldValue) {
            assertEquals(newValue, 10);
            assertEquals(oldValue, 1);
        }).once();
        value._ = 10;
        assertEquals(value._, 10);
        assertTrue(fired);

        fired = false;
        value._ = value._;
        assertFalse(fired);
    }

    public function testPromises ()
    {
        var promise = new Promise<Int>();
        assertFalse(promise.hasResult);

        assertThrows("Promise result not yet available", function () promise.result);

        var fired = 0;
        promise.get(function (n) fired = n);
        promise.result = 1;
        assertEquals(fired, 1);
        assertEquals(promise.result, 1);

        assertThrows("Promise result already assigned", function () promise.result = 2);
    }

    public function assertThrows (expectedError :Dynamic, fn :Void -> Void)
    {
        try {
            fn();
            assertTrue(false);
        } catch (e :Dynamic) {
            assertEquals(e, expectedError);
        }
    }
}
