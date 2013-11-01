package flambe.tilemapparallaxnodes;

/**
 * Todo
 * @author Ang Li
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
	
	public static function unzipBase64AsArray(input : String, lineWidth : Int, ?bytes : Int = 1) : Array<Array<Int>>{
		var dec : String  = unzipBase64(input);
		var ar : Array<Int> = [];
		var len : Int = Std.int(dec.length / bytes);
		
		for (i in 0...len) {
			ar[i] = 0;
			var j = bytes - 1;
			while (j >= 0) {
			//for (j = bytes - 1; j >= 0; --j) {
				var t = dec.charCodeAt((i * bytes) + j) << (j * 8);
				ar[i] += t;
				//trace(t);
				j--;
			}
		}
		//trace(ar);
		var ret : Array<Array<Int>> = new Array<Array<Int>>();
		for (i in 0...lineWidth) {
			ret[i] = new Array<Int>();
		}
		//ret.push(row);
		var count : Int = 0;
		var row : Int = 0;
		var col : Int = 0;
		for (i in 0...ar.length) {
			if (col == lineWidth) {
				row++;
				col = 0;
			}
			
			ret[row][col] = ar[i];
			col++;
			
		}
		//trace(ret);
		return ret;
	}
}