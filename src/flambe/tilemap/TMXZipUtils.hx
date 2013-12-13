package flambe.tilemap;

/**
 * 
 * @author Ang Li(李昂)
 */
class TMXZipUtils
{

	public function new() 
	{
		
	}
	
	public static function unzipBase64(input : String) : String {
		var tmpInput = TMXBase64.decode(input);
		return TMXGZip.gunzip(tmpInput);
	}
	
	public static function unzipBase64AsArray(input : String, lineWidth : Int, ?bytes : Int = 1) : Array<Int>{
		var dec : String  = unzipBase64(input);
		var ar : Array<Int> = [];
		var len : Int = Std.int(dec.length / bytes);
		
		for (i in 0...len) {
			ar[i] = 0;
			var j = bytes - 1;
			while (j >= 0) {
				var t = dec.charCodeAt((i * bytes) + j) << (j * 8);
				ar[i] += t;
				j--;
			}
		}
		return ar;
	}
}