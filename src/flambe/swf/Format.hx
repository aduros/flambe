//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.swf;

// Documents Flump's JSON format and adds some type-safety to parsing

typedef Format = {
    // The file format version number
    version: Int,

    // A checksum of the original XFL library used to generate this file, used by the exporter tool
    // to detect modifications
    checksum: String,

    // All the movies and atlases in the library
    movies: Array<MovieFormat>,
    atlases: Array<AtlasFormat>,
}

typedef MovieFormat = {
    // The symbol name of this movie
    symbol: String,

    layers: Array<LayerFormat>,
}

typedef LayerFormat = {
    // The name of the layer in Flash
    name: String,

    // Whether this is a flipbook-style animation
    flipbook: Bool,

    keyframes: Array<KeyframeFormat>,
}

typedef KeyframeFormat = {
    // The frame in the timeline that this keyframe is on
    index: Int,

    // The number of frames until the next keyframe
    duration: Int,

    // Optional: The name of the symbol that should be shown at this keyframe
    ref: Null<String>,

    // Optional: Symbol transform properties [ x, y, scaleX, scaleY, rotation (radians) ]
    t: Null<Array<Float>>,

    // Optional: Symbol transform properties [ x, y, scaleX, scaleY, rotation (radians) ]
    pivot: Null<Array<Float>>,

    // Optional: Symbol alpha
    alpha: Null<Float>,

    // Optional: The frame label that was added to this keyframe in Flash
    label: Null<String>,
}

typedef AtlasFormat = {
    // The path to the atlas
    file: String,

    // The textures packed in this atlas
    textures: Array<TextureFormat>,
}

typedef TextureFormat = {
    // The symbol name of this texture
    name: String,

    // The origin point relative to top-left of the texture rectangle
    offset: Array<Float>,

    // The rectangle bounding the texture in its atlas
    rect: Array<Float>,
}
