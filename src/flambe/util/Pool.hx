//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;

import flambe.math.FMath;

using flambe.util.Arrays;

/**
 * A pool of reusable objects that can be used to avoid allocation.
 *
 * ```haxe
 * // Create a pool and preallocate it with 10 ExpensiveObjects.
 * var pool = new Pool(function () return new ExpensiveObject()).setSize(10);
 *
 * var obj = pool.take();
 * // ...
 * pool.put(obj);
 * ```
 */
class Pool<A>
{
    /**
     * @param allocator A function that creates a new object.
     */
    public function new (allocator :Void -> A)
    {
        _allocator = allocator;
        _freeObjects = [];
    }

    /**
     * Take an object from the pool. If the pool is empty, a new object will be allocated.
     *
     * You should later release the object back into the pool by calling `put()`.
     */
    public function take () :A
    {
        if (_freeObjects.length > 0) {
            return _freeObjects.pop();
        }
        var object = _allocator();
        Assert.that(object != null);
        return object;
    }

    /**
     * Put an object into the pool. This should be called to release objects previously claimed with
     * `take()`. Can also be called to pre-allocate the pool with new objects.
     */
    public function put (object :A)
    {
        Assert.that(object != null);
        if (_freeObjects.length < _capacity) {
            _freeObjects.push(object);
        }
    }

    /**
     * Resizes the pool. If the given size is larger than the current number of pooled objects, new
     * objects are allocated to expand the pool. Otherwise, objects are trimmed out of the pool.
     *
     * @returns This instance, for chaining.
     */
    public function setSize (size :Int) :Pool<A>
    {
        if (_freeObjects.length > size) {
            _freeObjects.resize(size);
        } else {
            var needed = size - _freeObjects.length;
            for (ii in 0...needed) {
                var object = _allocator();
                Assert.that(object != null);
                _freeObjects.push(object);
            }
        }
        return this;
    }

    /**
     * Sets the maximum capacity of the pool. By default, the pool can grow to any size.
     *
     * @returns This instance, for chaining.
     */
    public function setCapacity (capacity :Int) :Pool<A>
    {
        if (_freeObjects.length > capacity) {
            _freeObjects.resize(capacity);
        }
        _capacity = capacity;
        return this;
    }

    private var _allocator :Void -> A;
    private var _freeObjects :Array<A>;
    private var _capacity :Int = FMath.INT_MAX;
}
