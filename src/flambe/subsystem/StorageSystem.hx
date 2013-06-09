//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.subsystem;

/**
 * A simple key/value store that persists between sessions.
 */
interface StorageSystem
{
    /**
     * True if the environment supports persisted storage. Otherwise, the storage is backed by a
     * Map and not actually persisted between sessions.
     */
    var supported (get, null) :Bool;

    /**
     * Add a key to the storage, replacing any existing value.
     * @param value An object that can be serialized with haxe.Serializer.
     * @returns True if the value was successfully serialized and persisted.
     */
    function set (key :String, value :Dynamic) :Bool;

    /**
     * Retrieve a value from storage for a given key.
     * @param defaultValue If the key was not found, return this value.
     */
    function get<A> (key :String, defaultValue :A = null) :A;

    /** Deletes a key/value pair from storage. */
    function remove (key :String) :Void;

    /** Clears the entire storage contents. */
    function clear () :Void;
}
