package flambe.display;

class ImageSprite extends Sprite
{
    public var texture :Texture;

    public function new (texture :Texture)
    {
        super();
        this.texture = texture;
    }

    override public function draw (ctx)
    {
        ctx.drawTexture(texture, 0, 0);
    }

    override public function getNaturalWidth () :Int
    {
        return texture.width;
    }

    override public function getNaturalHeight () :Int
    {
        return texture.height;
    }
}
