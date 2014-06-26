//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.script;

import flambe.swf.MoviePlayer;
import flambe.swf.MovieSprite;

/**
 * An action that plays a movie once using the actor's MoviePlayer, completing when the movie
 * finishes.
 */
class PlayMovie
    implements Action
{
    /**
     * @param The name of the movie to play.
     */
    public function new (name :String)
    {
        _name = name;
    }

    public function update (dt :Float, actor :Entity) :Float
    {
        var player = actor.get(MoviePlayer);
        if (_movie == null) {
            player.play(_name);
            _movie = player.movie._;

        } else if (_movie != player.movie._) {
            _movie = null;
            return 0;
        }

        return -1; // Keep going
    }

    private var _name :String;
    private var _movie :MovieSprite = null;
}
