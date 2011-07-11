//
// Flambe - Rapid game development
// https://github.com/aduros/amity/blob/master/LICENSE.txt

package flambe.platform;

interface Storage
{
    /**
     * Add a key to the storage, replacing any existing value.
     * @return True if the value was successfully persisted.
     */
    function set (key :String, value :String) :Bool;

    /** Retrieve a value from storage for a given key. */
    function get (key :String) :String;

    /** Deletes a key/value pair from storage. */
    function remove (key :String) :Void;

    /** Deletes entire storage contents. */
    function clear () :Void;
}
