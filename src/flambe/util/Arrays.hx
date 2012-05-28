//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;

/**
 * Utility mixins for Arrays. Designed to be imported with 'using'.
 */
class Arrays
{
    public static function sortedInsert<A> (arr :Array<A>, val :A, comp :A -> A -> Int) :Int
    {
        var insertedIdx = -1;
        var nn = arr.length;
        for (ii in 0...nn) {
            var compVal = arr[ii];
            if (comp(val, compVal) <= 0) {
                arr.insert(ii, val);
                insertedIdx = ii;
                break;
            }
        }

        if (insertedIdx < 0) {
            arr.push(val);
            insertedIdx = arr.length - 1;
        }

        return insertedIdx;
    }
}
