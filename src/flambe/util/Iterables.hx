//
// Flambe - Rapid game development
// https://github.com/aduros/amity/blob/master/LICENSE.txt

package flambe.util;

class Iterables
{
    /**
     * Searches for the first element using a predicate and returns it.
     */
    public static function find<A> (it :Iterable<A>, pred :A -> Bool) :A
    {
        for (a in it) {
            if (pred(a)) {
                return a;
            }
        }
        return null;
    }
}
