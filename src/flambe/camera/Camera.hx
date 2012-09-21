package flambe.camera;
import flambe.math.Matrix;
import flambe.display.Sprite;
import flambe.Component;
class Camera extends Component {

  
    private var m_background:Sprite;
    private var m_midground:Sprite;
    private var m_foreground:Sprite;
    private var m_bird:Sprite;
    private var m_worldToScreen:Matrix;
    private var m_screenToWorld:Matrix;
    public function new(background:Sprite, midground:Sprite, foreground:Sprite, bird:Sprite) {

        this.m_background = background;
        this.m_midground = midground;
        this.m_foreground = foreground;
        this.m_bird = bird;
        this.m_scale = new Vector2(1, 1);
    }


    override public function onUpdate(dt:Float) {


        var translate:Vector2 //= this.m_bird.
        var screenHalfExtents:Vector2 = new Vector2((Constants.kScreenDimensions.m_x / 2), (Constants.kScreenDimensions.m_y / 2)).Div(new Vector2(this.m_scale.m_x, this.m_scale.m_y));
        var mapExtents:Vector2 = Constants.kWorldAabb.m_HalfExtents.MulScalar(2);
        var topLeft:Vector2 = this.m_bird.m_Pos.Sub(screenHalfExtents);
        var bottomRight:Vector2 = this.m_bird.m_Pos.Add(screenHalfExtents);
        var correctLeft:Float = Math.min((topLeft.m_x + Constants.kWorldAabb.m_HalfExtents.m_x), 0);
        var correctTop:Float = Math.min((topLeft.m_y + Constants.kWorldAabb.m_HalfExtents.m_y), 0);
        var correctRight:Float = Math.min((Constants.kWorldAabb.m_HalfExtents.m_x - bottomRight.m_x), 0);
        var correctBottom:Float = Math.min((Constants.kWorldAabb.m_HalfExtents.m_y - bottomRight.m_y), 0);
        translate.m_x = (translate.m_x + (correctLeft - correctRight));
        translate.m_y = (translate.m_y + (correctTop - correctBottom));
        this.m_worldToScreen = new Matrix();
        this.m_worldToScreen.translate(translate.m_x, translate.m_y);
        this.m_worldToScreen.scale(this.m_scale.m_x, this.m_scale.m_y);
        this.m_worldToScreen.translate((Constants.kScreenDimensions.m_x / 2), (Constants.kScreenDimensions.m_y / 2));
        var worldToScreenBackground:Matrix = new Matrix();
        worldToScreenBackground.translate((translate.m_x / kBackgroundZ), translate.m_y);
        worldToScreenBackground.scale(this.m_scale.m_x, this.m_scale.m_y);
        worldToScreenBackground.translate((Constants.kScreenDimensions.m_x / 2), (Constants.kScreenDimensions.m_y / 2));
        var worldToScreenMidground:Matrix = new Matrix();
        worldToScreenMidground.translate((translate.m_x / kMidgroundZ), translate.m_y);
        worldToScreenMidground.scale(this.m_scale.m_x, this.m_scale.m_y);
        worldToScreenMidground.translate((Constants.kScreenDimensions.m_x / 2), (Constants.kScreenDimensions.m_y / 2));
        this.m_foreground.transform.matrix = this.m_worldToScreen;
        this.m_background. = worldToScreenBackground;
        this.m_midground.transform.matrix = worldToScreenMidground;
        this.m_screenToWorld = this.m_worldToScreen.clone();
        this.m_screenToWorld.invert();
    }

}
