package flambe.tilemap;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.zip.InflateImpl;
#if flash
import flash.utils.ByteArray;
import flash.utils.Endian;
#end

class TMXBase64
{

	public function new() 
	{
		
	}
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

		while (i < input.length) {
			enc1 = BASE64_CHARS.indexOf(input.charAt(i++));
			enc2 = BASE64_CHARS.indexOf(input.charAt(i++));
			enc3 = BASE64_CHARS.indexOf(input.charAt(i++));
			enc4 = BASE64_CHARS.indexOf(input.charAt(i++));

			chr1 = (enc1 << 2) | (enc2 >> 4);
			chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
			chr3 = ((enc3 & 3) << 6) | enc4;

			output.push(String.fromCharCode(chr1));
			if (enc3 != 64) {
				output.push(String.fromCharCode(chr2));
			}
			if (enc4 != 64) {
				output.push(String.fromCharCode(chr3));
			}
		}

		var o : String = output.join('');
		var count : Int = 0;
		for (i in output) {
			var x = i.charCodeAt(0);
			count++;
		}
		return o;
	}
	
	public static function decodeAsArray(input : String , lineWidth : Int , ?bytes : Int = 4) : Array<Int> {
		var dec : String  = decode(input);
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
	
	private static function decodeAsOneArray(input : String , lineWidth : Int , ?bytes : Int = 4) : Array<Int> {
		var dec : String  = decode(input);
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
	
	private static function decodeAsArrayBytes(byte : Bytes , lineWidth : Int , ?bytes : Int = 4) : Array<Int> {
		var ar : Array<Int> = [];
		var len : Int = Std.int(byte.length / bytes);
		
		for (i in 0...len) {
			ar[i] = 0;
			var j = bytes - 1;
			while (j >= 0) {
				var t = byte.get((i * bytes) + j) << (j * 8);
				ar[i] += t;
				j--;
			}
		}
		
		return ar;
	}
	
	#if js
	public static function unzip(input : String, lineWidth : Int ) : Array<Int> {
		var tempString1 : String = decode(input);
		var arr : Array<Int> = TMXBase64.decodeAsOneArray(input, 0, 1);
	
		var b = Bytes.ofData(cast arr);
		var bytes : Bytes = InflateImpl.run(new BytesInput(b));
		var ret : Array<Int> = TMXBase64.decodeAsArrayBytes(bytes, lineWidth);
		
		return ret;
	}
	#end
	
	#if flash
	public static function unzip(chunk : String, lineWidth : Int) : Array<Int> {
		var result:Array<Int> = new Array<Int>();
		var data:ByteArray = base64ToByteArray(chunk);
		data.uncompress();
		data.endian = Endian.LITTLE_ENDIAN;
		while(data.position < data.length)
		{

			result.push(data.readInt());
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