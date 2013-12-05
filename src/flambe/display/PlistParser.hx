package dev.display;
import flambe.asset.AssetPack;

/**
 * Parser for Texture Packer
 * @author Ang Li(李昂)
 */
class PlistParser
{
	public function new() 
	{
	}
	
	
	public static function parse(xmlDoc : Xml) : Array<PlistEntry> {
		var plist = new Array<PlistEntry>();
		var frames : Xml = null;
		var metadata : Xml = null;
		var index : Int = 0;
		for (x in xmlDoc.firstElement().firstElement().elements()) {
			if (x.firstChild().nodeValue == "frames") {
				index = 1;
			} else if (x.nodeName == "dict" && index == 1) {
				frames = x;
			} else if (x.firstChild().nodeValue == "metadata") {
				index = 2;
			} else if (x.nodeName == "dict" && index == 2) {
				metadata = x;
			}
		}
		
		index = 1;
		var tempEntry : PlistEntry = new PlistEntry();
		var tempKey : String = "";
		for (x in frames.elements()) {
			if (x.nodeName == "key" && index == 1) {
				
				tempEntry.name = x.firstChild().nodeValue;
				index = 2;
			} else if (x.nodeName == "dict" && index == 2) {
				index = 1;
				for (info in x.elements()) {
					if (info.nodeName == "key") {
						tempKey = info.firstChild().nodeValue;
					} else {
						switch(tempKey) {
							case "frame" : 
								var s : Array<Float> = parseString(info.firstChild().nodeValue);
								tempEntry.x = s[0];
								tempEntry.y = s[1];
								tempEntry.width = s[2];
								tempEntry.height = s[3];
								
							case "sourceColorRect":
								var s : Array<Float> = parseString(info.firstChild().nodeValue);
								tempEntry.sourceColorX = s[0];
								tempEntry.sourceColorY = s[1];
								
							case "rotated":
								if (info.nodeName == "true") {
									tempEntry.rotated = true;
								} else {
									tempEntry.rotated = false;
								}	
						}
					}
				}
				plist.push(new PlistEntry(tempEntry));
			}
		}
		return plist;
	}
	
	public static function parseString(str : String) : Array<Float> {
		var ret : Array<Float> = new Array<Float>();
		var index : Int;
		var temp : String;
		var buf : StringBuf = new StringBuf();
		
		for (i in 0...str.length) {
			if (str.charAt(i) != "{" && str.charAt(i) != "}") {
				buf.addSub(str.charAt(i), 0);
			}
		}
		
		var newString : String = buf.toString();
		for (i in newString.split(",")) {
			ret.push(Std.parseFloat(i));
		}
		
		return ret;
	}
}