//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.html.*;

class CanvasTexture extends BasicTexture<CanvasTextureRoot>
{
    public function new (root :CanvasTextureRoot, width :Int, height :Int)
    {
        super(root, width, height);
    }

    public function getPattern () :CanvasPattern
    {
        if (_rootUpdateCount != root.updateCount || _pattern == null) {
            _rootUpdateCount = root.updateCount;
            _pattern = root.createPattern(rootX, rootY, width, height);
        }
        return _pattern;
    }

    private var _pattern :CanvasPattern = null;
    private var _rootUpdateCount :Int = 0;
}
