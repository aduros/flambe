//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.swf;

// Documents Flump's JSON format and adds some type-safety to parsing

typedef Format = {
    // A checksum of the original FLA library used to generate this file, used by the exporter tool
    // to detect modifications
    md5: String,

    // The frame rate as exported from Flash
    frameRate: Float,

    // All the movies and atlases in the library
    movies: Array<MovieFormat>,
    textureGroups: Array<TextureGroupFormat>,
}

typedef TextureGroupFormat = {
    // The additional scale factor (not supported in Flambe, use different base scales instead)
    scaleFactor: Float,

    // The atlases in this scale group
    atlases: Array<AtlasFormat>,
}

typedef MovieFormat = {
    // The symbol name of this movie
    // TODO(bruno): Why not call it symbol? Movies share the same namespace as textures
    id: String,

    layers: Array<LayerFormat>,
}

typedef LayerFormat = {
    // The name of the layer in Flash
    name: String,

    // Optional: Whether this is a flipbook-style animation. Defaults to false
    flipbook: Null<Bool>,

    keyframes: Array<KeyframeFormat>,
}

typedef KeyframeFormat = {
    // The number of frames until the next keyframe
    duration: Float,

    // Optional: The name of the symbol that should be shown at this keyframe
    ref: Null<String>,

    // Optional: Transform [x, y] properties. Defaults to [0, 0]
    loc: Null<Array<Float>>,

    // Optional: Transform [scaleX, scaleY] properties. Defaults to [1, 1]
    scale: Null<Array<Float>>,

    // Optional: Transform [skewX, skewY] in radians. Defaults to 0
    skew: Null<Array<Float>>,

    // Optional: The anchor point [x, y]. Defaults to [0, 0]
    pivot: Null<Array<Float>>,

    // Optional: Symbol alpha. Defaults to 1.0
    alpha: Null<Float>,

    // Optional: The frame label that was added to this keyframe in Flash
    label: Null<String>,

    // Optional: Whether this keyframe should be displayed. Defaults to true
    visible: Null<Bool>,

    // Optional: Whether this keyframe is tweened into the next. Defaults to true
    tweened: Null<Bool>,

    // Optional: Easing factor to tween this keyframe's properties, from -1.0 to 1.0. Defaults to 0
    ease: Null<Float>,
}

typedef AtlasFormat = {
    // The path to the atlas
    file: String,

    // The textures packed in this atlas
    textures: Array<TextureFormat>,
}

typedef TextureFormat = {
    // The symbol name of this texture
    symbol: String,

    // The bitmap's anchor point, relative to the top left of its rect
    origin: Array<Float>,

    // The rectangle bounding the texture in its atlas
    rect: Array<Int>,
}
