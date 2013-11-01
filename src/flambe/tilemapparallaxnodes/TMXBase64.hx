package flambe.tilemapparallaxnodes;


import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.zip.InflateImpl;
#if flash
import flash.utils.ByteArray;
import flash.utils.Endian;
#end
/**
 * decodeAsArray and base64ToByteArray are copied from
 * https://github.com/po8rewq/HaxeFlixelTiled/blob/master/org/flixel/tmx/TmxLayer.hx
 */
class TMXBase64
{

	public function new() 
	{
		
	}
	
	//public function decode(input : String) : String {
		//
	//}
	
	//Only for Tiledmap

	private static inline var BASE64_CHARS:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

	
	public static  function decode(input : String ) : String {
		input = StringTools.ltrim(input);
		input = StringTools.rtrim(input);
		var output : Array<String> = [];
		var enc1 : Int;
		var enc2 : Int;
		var enc3 : Int;
		var enc4 : Int;
		var i : Int  = 0;
		var chr1 : Int;
		var chr2 : Int;
		var chr3 : Int;
//
		//input.
		//input = input.replace(/[^A-Za-z0-9\+\/\=]/g, "");

		while (i < input.length) {
			enc1 = BASE64_CHARS.indexOf(input.charAt(i++));
			enc2 = BASE64_CHARS.indexOf(input.charAt(i++));
			enc3 = BASE64_CHARS.indexOf(input.charAt(i++));
			enc4 = BASE64_CHARS.indexOf(input.charAt(i++));
			//trace(enc1 + " " + enc2 + " " + enc3 + " ");

			chr1 = (enc1 << 2) | (enc2 >> 4);
			chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
			chr3 = ((enc3 & 3) << 6) | enc4;

			output.push(String.fromCharCode(chr1));
			//trace(chr1);
			if (enc3 != 64) {
				output.push(String.fromCharCode(chr2));
				//trace(chr2);
			}
			if (enc4 != 64) {
				output.push(String.fromCharCode(chr3));
				//trace(chr3);
			}
		}

		var o : String = output.join('');
		var count : Int = 0;
		for (i in output) {
			var x = i.charCodeAt(0);
			if (x != 0) {
				//trace('i = $count, code = $x');
				//trace(o.charCodeAt(count));
			}
			count++;
		}
		//trace(output);
		return o;
	}
	
	public static function decodeAsArray(input : String , lineWidth : Int , ?bytes : Int = 4) : Array<Array<Int>> {
		//trace(input);
		var dec : String  = decode(input);
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
		//trace(ar.length);
		//trace(lineWidth);
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
	
	private static function decodeAsOneArray(input : String , lineWidth : Int , ?bytes : Int = 4) : Array<Int> {
		//trace(input);
		var dec : String  = decode(input);
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
		return ar;
	}
	
	private static function decodeAsArrayBytes(byte : Bytes , lineWidth : Int , ?bytes : Int = 4) : Array<Array<Int>> {
		//trace(input);
		//var dec : String  = decode(input);
		var ar : Array<Int> = [];
		var len : Int = Std.int(byte.length / bytes);
		
		for (i in 0...len) {
			ar[i] = 0;
			var j = bytes - 1;
			while (j >= 0) {
			//for (j = bytes - 1; j >= 0; --j) {
				var t = byte.get((i * bytes) + j) << (j * 8);
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
	
	#if js
	public static function unzip(input : String, lineWidth : Int ) : Array<Array<Int>> {
		var tempString1 : String = decode(input);
		var arr : Array<Int> = CCBase64.decodeAsOneArray(input, 0, 1);
		//trace(arr);
	
		var b = Bytes.ofData(cast arr);
		var bytes : Bytes = InflateImpl.run(new BytesInput(b));
		//trace(bytes.toString());
		//trace('b.length = ${b.length}, arr.length = ${arr.length}');
		//trace(bytes.length);
		var ret : Array<Array<Int>> = CCBase64.decodeAsArrayBytes(bytes, lineWidth);
		
		return ret;
	}
	#end
	
	#if flash
	public static function unzip(chunk : String, lineWidth : Int) : Array<Array<Int>> {
		var result:Array<Array<Int>> = new Array<Array<Int>>();
		var data:ByteArray = base64ToByteArray(chunk);
		data.uncompress();
		data.endian = Endian.LITTLE_ENDIAN;
		while(data.position < data.length)
		{
			var resultRow:Array<Int> = new Array<Int>();
			var i:Int;
			for (i in 0...lineWidth)
				resultRow.push(data.readInt());
			result.push(resultRow);
		}
		return result;
	}
	
	private static function base64ToByteArray(data:String):ByteArray 
	{
		var output:ByteArray = new ByteArray();

		var lookup:Array<Int> = new Array<Int>();
		var c:Int;
		for (c in 0...BASE64_CHARS.length)
		{
			lookup[BASE64_CHARS.charCodeAt(c)] = c;
		}

		var i:Int = 0;
		while (i < data.length - 3) 
		{
			if (data.charAt(i) == " " || data.charAt(i) == "\n")
			{
				i++; continue;
			}

			var a0:Int = lookup[data.charCodeAt(i)];
			var a1:Int = lookup[data.charCodeAt(i + 1)];
			var a2:Int = lookup[data.charCodeAt(i + 2)];
			var a3:Int = lookup[data.charCodeAt(i + 3)];

			 //convert to and write 3 bytes
			if(a1 < 64)
				output.writeByte((a0 << 2) + ((a1 & 0x30) >> 4));
			if(a2 < 64)
				output.writeByte(((a1 & 0x0f) << 4) + ((a2 & 0x3c) >> 2));
			if(a3 < 64)
				output.writeByte(((a2 & 0x03) << 6) + a3);

			i += 4;
		}

		output.position = 0;
		return output;
	}
	#end
	
	
}