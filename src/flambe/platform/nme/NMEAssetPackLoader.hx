//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.nme;

import nme.display.Bitmap;
import nme.errors.Error;
import nme.system.Capabilities;
import nme.Assets;

import flambe.asset.AssetEntry;
import flambe.asset.Manifest;
import flambe.platform.BasicAssetPackLoader;

class NMEAssetPackLoader extends BasicAssetPackLoader
{
    public function new (manifest :Manifest)
    {
        super(manifest);
    }

    override private function loadEntry (entry :AssetEntry)
    {
    	var name = entry.url.substr (0, entry.url.indexOf ("?"));
    	
        try switch (entry.type) {
            case Image:
            
            	var texture = new NMETexture (Assets.getBitmapData (name));
            	handleLoad (entry, texture);

            case Audio:
                
                var sound = new NMESound (Assets.getSound (name));
                handleLoad (entry, sound);

            case Data:
                
                var text = Assets.getText (name);
                handleLoad (entry, text);

        } catch (error :Error) {
            handleError(error.message);
            return;
        }
    }

    override private function getAudioFormats () :Array<String>
    {
        // TODO(bruno): Flash actually has an m4a decoder, but it's only accessible through the
        // horrendous NetStream API and not good old flash.media.Sound
        return [ "wav", "ogg", "mp3" ];
        //return (Capabilities.hasAudio && Capabilities.hasMP3) ? [ "mp3" ] : [];
    }
}
