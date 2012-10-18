//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.storage;

/**
 * A simple key/value store that persists between sessions.
 */
interface Storage
{
    /**
     * True if the environment supports persisted storage. Otherwise, the storage is backed by a
     * Hash and not actually persisted between sessions.
     */
    var supported (isSupported, null) :Bool;

    /**
     * Add a key to the storage, replacing any existing value.
     * @param value An object that can be serialized with haxe.Serializer.
     * @returns True if the value was successfully serialized and persisted.
     */
    function set (key :String, value :Dynamic) :Bool;

    /** Retrieve a value from storage for a given key. */
    function get (key :String) :Dynamic;

    /** Deletes a key/value pair from storage. */
    function remove (key :String) :Void;

    /** Deletes entire storage contents. */
    function clear () :Void;
}
