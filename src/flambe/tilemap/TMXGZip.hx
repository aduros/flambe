package flambe.tilemap;

/**
 * Haxe Port of https://github.com/cocos2d/cocos2d-html5/blob/develop/cocos2d/platform/gzip.js
 * @author Ang Li(李昂)
 */
class TMXGZip
{
	var data : String;
	var debug : Bool;
	var gpflags : Int;
	var files : Int;
	var unzipped : Array<Array<String>>;
	var buf32k : Array<Int>;
	var bIdx : Int;
	var modeZIP : Bool;
	var bytepos : Int;
	var bb : Int;
	var bits : Int;
	var nameBuf : Array<String>;
	var fileout : Array<String>;
	var literalTree : Array<HufNode>;
	var distanceTree : Array<HufNode>;
	var treepos : Int = 0;
	var Places : Array<HufNode>;
	var len : Int = 0;
	var fpos : Array<Int>;
	var flens : Array<Int>;
	var fmax : Int;
	
	var outputArr : Array<String>;
	
	public static var LITERALS : Int = 288;
	public static var NAMEMAX : Int = 256;
	public static var bitReverse : Array<Int> = [
		0x00, 0x80, 0x40, 0xc0, 0x20, 0xa0, 0x60, 0xe0,
		0x10, 0x90, 0x50, 0xd0, 0x30, 0xb0, 0x70, 0xf0,
		0x08, 0x88, 0x48, 0xc8, 0x28, 0xa8, 0x68, 0xe8,
		0x18, 0x98, 0x58, 0xd8, 0x38, 0xb8, 0x78, 0xf8,
		0x04, 0x84, 0x44, 0xc4, 0x24, 0xa4, 0x64, 0xe4,
		0x14, 0x94, 0x54, 0xd4, 0x34, 0xb4, 0x74, 0xf4,
		0x0c, 0x8c, 0x4c, 0xcc, 0x2c, 0xac, 0x6c, 0xec,
		0x1c, 0x9c, 0x5c, 0xdc, 0x3c, 0xbc, 0x7c, 0xfc,
		0x02, 0x82, 0x42, 0xc2, 0x22, 0xa2, 0x62, 0xe2,
		0x12, 0x92, 0x52, 0xd2, 0x32, 0xb2, 0x72, 0xf2,
		0x0a, 0x8a, 0x4a, 0xca, 0x2a, 0xaa, 0x6a, 0xea,
		0x1a, 0x9a, 0x5a, 0xda, 0x3a, 0xba, 0x7a, 0xfa,
		0x06, 0x86, 0x46, 0xc6, 0x26, 0xa6, 0x66, 0xe6,
		0x16, 0x96, 0x56, 0xd6, 0x36, 0xb6, 0x76, 0xf6,
		0x0e, 0x8e, 0x4e, 0xce, 0x2e, 0xae, 0x6e, 0xee,
		0x1e, 0x9e, 0x5e, 0xde, 0x3e, 0xbe, 0x7e, 0xfe,
		0x01, 0x81, 0x41, 0xc1, 0x21, 0xa1, 0x61, 0xe1,
		0x11, 0x91, 0x51, 0xd1, 0x31, 0xb1, 0x71, 0xf1,
		0x09, 0x89, 0x49, 0xc9, 0x29, 0xa9, 0x69, 0xe9,
		0x19, 0x99, 0x59, 0xd9, 0x39, 0xb9, 0x79, 0xf9,
		0x05, 0x85, 0x45, 0xc5, 0x25, 0xa5, 0x65, 0xe5,
		0x15, 0x95, 0x55, 0xd5, 0x35, 0xb5, 0x75, 0xf5,
		0x0d, 0x8d, 0x4d, 0xcd, 0x2d, 0xad, 0x6d, 0xed,
		0x1d, 0x9d, 0x5d, 0xdd, 0x3d, 0xbd, 0x7d, 0xfd,
		0x03, 0x83, 0x43, 0xc3, 0x23, 0xa3, 0x63, 0xe3,
		0x13, 0x93, 0x53, 0xd3, 0x33, 0xb3, 0x73, 0xf3,
		0x0b, 0x8b, 0x4b, 0xcb, 0x2b, 0xab, 0x6b, 0xeb,
		0x1b, 0x9b, 0x5b, 0xdb, 0x3b, 0xbb, 0x7b, 0xfb,
		0x07, 0x87, 0x47, 0xc7, 0x27, 0xa7, 0x67, 0xe7,
		0x17, 0x97, 0x57, 0xd7, 0x37, 0xb7, 0x77, 0xf7,
		0x0f, 0x8f, 0x4f, 0xcf, 0x2f, 0xaf, 0x6f, 0xef,
		0x1f, 0x9f, 0x5f, 0xdf, 0x3f, 0xbf, 0x7f, 0xff
	];
	
	public static var cplens : Array<Int> = [
		3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31,
		35, 43, 51, 59, 67, 83, 99, 115, 131, 163, 195, 227, 258, 0, 0
	];
	
	public static var cplext : Array<Int>= [
		0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2,
		3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0, 99, 99
	];
	/* 99==invalid */
	public static var cpdist : Array<Int>= [
		0x0001, 0x0002, 0x0003, 0x0004, 0x0005, 0x0007, 0x0009, 0x000d,
		0x0011, 0x0019, 0x0021, 0x0031, 0x0041, 0x0061, 0x0081, 0x00c1,
		0x0101, 0x0181, 0x0201, 0x0301, 0x0401, 0x0601, 0x0801, 0x0c01,
		0x1001, 0x1801, 0x2001, 0x3001, 0x4001, 0x6001
	];
	
	public static var cpdext : Array<Int>= [
		0, 0, 0, 0, 1, 1, 2, 2,
		3, 3, 4, 4, 5, 5, 6, 6,
		7, 7, 8, 8, 9, 9, 10, 10,
		11, 11, 12, 12, 13, 13
	];
	
	public static var border : Array<Int>= [16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15];
	
	public function new(data : String) 
	{
		this.data = data;
		this.debug = false;
		this.gpflags = 0;
		this.files = 0;
		this.unzipped = [];
		this.buf32k = new Array();
		this.bIdx = 0;
		this.modeZIP = false;
		this.bytepos = 0;
		this.bb = 1;
		this.bits = 0;
		this.nameBuf = [];
		this.fileout = new Array();
		this.literalTree = new Array();
		this.literalTree[LITERALS - 1] = new HufNode();
		this.distanceTree = new Array();
		this.distanceTree[31] = new HufNode();
		this.treepos = 0;
		this.Places = null;
		this.len = 0;
		this.fpos = new Array();
		this.fpos[16] = 0;
		this.fpos[0] = 0;
		this.flens = new Array<Int>();
		this.fmax = 0;
	}
	
	public static function gunzip(data : String) : String {
		var gzip : TMXGZip= new TMXGZip(data);
		return gzip.gunzipLocal();
	}
	
	
	public function gunzipLocal() : String {
		outputArr = new Array<String>();
		this.nextFile();
		return this.unzipped[0][0];
	}
	
	
	public function readByte() : Int{
		this.bits += 8;
		if (this.bytepos < this.data.length) {
			return this.data.charCodeAt(this.bytepos++);
		} else {
			return -1;
		}
	}
	
	public function byteAlign() {
		this.bb = 1;
	}
	
	public function readBit() : Int {
		this.bits++;
		var carry = this.bb & 1;
		this.bb >>= 1;
		if (this.bb == 0) {
			this.bb = this.readByte();
			carry = this.bb & 1;
			this.bb = (this.bb >> 1) | 0x80;
		}
		return carry;
	}
	
	public function readBits(a : Int) {
		var res : Int = 0;
		var i : Int = a;
		while (i != 0) {
			res = (res << 1) | this.readBit();
			i--;
		}
		
		if (a != 0) {
			res = bitReverse[res] >> (8 - a);
		}
		return res;
	}
	
	public function flushBuffer() {
		this.bIdx = 0;
	}
	
	public function addBuffer(a : Int) {
		this.buf32k[this.bIdx++] = a;
		this.outputArr.push(String.fromCharCode(a));
		if (this.bIdx == 0x8000) this.bIdx = 0;
	}
	
	public function isPat() : Int {
		while (true) {
			if (this.fpos[this.len] >= this.fmax)    return -1;
			if (this.flens[this.fpos[this.len]] == this.len) return this.fpos[this.len]++;
			this.fpos[this.len]++;
		}
	}
	
	public function rec() : Int {
		//trace(Places.length);
		//trace('treepos = $treepos');
		var curplace : HufNode = this.Places[this.treepos];
		var tmp : Int ;
		//if (this.debug) document.write("<br>len:"+this.len+" treepos:"+this.treepos);
		if (this.len == 17) { //war 17
			return -1;
		}
		this.treepos++;
		this.len++;

		tmp = this.isPat();
		//if (this.debug) document.write("<br>IsPat "+tmp);
		if (tmp >= 0) {
			curplace.b0 = tmp;
			/* leaf cell for 0-bit */
			//if (this.debug) document.write("<br>b0 "+curplace.b0);
		} else {
			/* Not a Leaf cell */
			curplace.b0 = 0x8000;
			//if (this.debug) document.write("<br>b0 "+curplace.b0);
			if (this.rec() != 0) return -1;
		}
		tmp = this.isPat();
		if (tmp >= 0) {
			curplace.b1 = tmp;
			/* leaf cell for 1-bit */
			//if (this.debug) document.write("<br>b1 "+curplace.b1);
			curplace.jump = null;
			/* Just for the display routine */
		} else {
			/* Not a Leaf cell */
			curplace.b1 = 0x8000;
			//if (this.debug) document.write("<br>b1 "+curplace.b1);
			curplace.jump = this.Places[this.treepos];
			curplace.jumppos = this.treepos;
			if (this.rec() != 0) return -1;
		}
		this.len--;
		return 0;
	}
	
	public function createTree(currentTree : Array<HufNode>, numval : Int , lengths : Array<Int>, show : Int ) : Int {
		this.Places = currentTree;
		this.treepos = 0;
		this.flens = lengths;
		this.fmax = numval;
		
		for (i in 0...17) {
			this.fpos[i] = 0;
		}
		
		this.len = 0;
		if (this.rec() != 0) {
			return -1;
		}
		
		return 0;
	}
	
	public function decodeValue(currentTree : Array<HufNode>) : Int {
		var len : Int = 0;
		var xtreepos : Int = 0;
        var X : HufNode = currentTree[xtreepos];
        var b : Int = 0;

		/* decode one symbol of the data */
		while (true) {
			b = this.readBit();
			// if (this.debug) document.write("b="+b);
			if (b != 0) {
				if ((X.b1 & 0x8000) == 0) {
					// if (this.debug) document.write("ret1");
					return X.b1;
					/* If leaf node, return data */
				}
				X = X.jump;
				len = currentTree.length;
				for (i in 0...len) {
					if (currentTree[i] == X) {
						xtreepos = i;
						break;
					}
				}
			} else {
				if ((X.b0 & 0x8000) == 0) {
					// if (this.debug) document.write("ret2");
					return X.b0;
					/* If leaf node, return data */
				}
				xtreepos++;
				X = currentTree[xtreepos];
			}
		}
		// if (this.debug) document.write("ret3");

		return -1;
	}
	
	public function deflateLoop() : Int {
		var last : Int, c : Int , type : Int, len : Int = 0, i : Int ;
		do {
			last = this.readBit();
			type = this.readBits(2);
			//trace('type = $type');
			if (type == 0) {
				var blockLen, cSum : Int = 0;

				// Stored
				this.byteAlign();
				blockLen = this.readByte();
				blockLen |= (this.readByte() << 8);

				cSum = this.readByte();
				cSum |= (this.readByte() << 8);

				if (((blockLen ^ ~cSum) & 0xffff) != 0) {
					throw "BlockLen checksum mismatch\n"; // FIXME: use throw
				}
				while ((blockLen--) != 0) {
					c = this.readByte();
					this.addBuffer(c);
				}
			} else if (type == 1) {
				var j : Int ;

				/* Fixed Huffman tables -- fixed decode routine */
				while (true) {
					/*
					 256    0000000        0
					 :   :     :
					 279    0010111        23
					 0   00110000    48
					 :    :      :
					 143    10111111    191
					 280 11000000    192
					 :    :      :
					 287 11000111    199
					 144    110010000    400
					 :    :       :
					 255    111111111    511

					 Note the bit order!
					 */
					j = (bitReverse[this.readBits(7)] >> 1);
					if (j > 23) {
						j = (j << 1) | this.readBit();
						/* 48..255 */

						if (j > 199) {              /* 200..255 */
							j -= 128;
							/*  72..127 */
							j = (j << 1) | this.readBit();
							/* 144..255 << */
						} else {                    /*  48..199 */
							j -= 48;
							/*   0..151 */
							if (j > 143) {
								j = j + 136;
								/* 280..287 << */
								/*   0..143 << */
							}
						}
					} else {                      /*   0..23 */
						j += 256;
						/* 256..279 << */
					}
					if (j < 256) {
						this.addBuffer(j);
					} else if (j == 256) {
						/* EOF */
						break; // FIXME: make this the loop-condition
					} else {
						var len, dist;

						j -= 256 + 1;
						/* bytes + EOF */
						len = this.readBits(cplext[j]) + cplens[j];

						j = bitReverse[this.readBits(5)] >> 3;
						if (cpdext[j] > 8) {
							dist = this.readBits(8);
							dist |= (this.readBits(cpdext[j] - 8) << 8);
						} else {
							dist = this.readBits(cpdext[j]);
						}
						dist += cpdist[j];

						for (j in 0...len) {
							var c = this.buf32k[(this.bIdx - dist) & 0x7fff];
							this.addBuffer(c);
						}
					}
				} // while

			} else if (type == 2) {
				var j : Int , n : Int, literalCodes : Int, distCodes : Int, lenCodes : Int;
				var ll : Array<Int>= new Array();    // "static" just to preserve stack

				// Dynamic Huffman tables

				literalCodes = 257 + this.readBits(5);
				distCodes = 1 + this.readBits(5);
				lenCodes = 4 + this.readBits(4);
				for (j in 0...19) {
					ll[j] = 0;
				}

				// Get the decode tree code lengths

				for (j in 0...lenCodes) {
					ll[border[j]] = this.readBits(3);
				}
				len = this.distanceTree.length;
				//trace('len = $len');
				for (i in 0... len) this.distanceTree[i] = new HufNode();
				if (this.createTree(this.distanceTree, 19, ll, 0) != 0) {
					this.flushBuffer();
					return 1;
				}
				// if (this.debug) {
				//   document.write("<br>distanceTree");
				//   for(var a=0;a<this.distanceTree.length;a++){
				//     document.write("<br>"+this.distanceTree[a].b0+" "+this.distanceTree[a].b1+" "+this.distanceTree[a].jump+" "+this.distanceTree[a].jumppos);
				//   }
				// }

				//read in literal and distance code lengths
				n = literalCodes + distCodes;
				i = 0;
				var z = -1;
				// if (this.debug) document.write("<br>n="+n+" bits: "+this.bits+"<br>");
				while (i < n) {
					z++;
					j = this.decodeValue(this.distanceTree);
					// if (this.debug) document.write("<br>"+z+" i:"+i+" decode: "+j+"    bits "+this.bits+"<br>");
					if (j < 16) {    // length of code in bits (0..15)
						ll[i++] = j;
					} else if (j == 16) {    // repeat last length 3 to 6 times
						var l;
						j = 3 + this.readBits(2);
						if (i + j > n) {
							this.flushBuffer();
							return 1;
						}
						l = (i != 0) ? ll[i - 1] : 0;
						while ( (j--) != 0) {
							ll[i++] = l;
						}
					} else {
						if (j == 17) {        // 3 to 10 zero length codes
							j = 3 + this.readBits(3);
						} else {        // j == 18: 11 to 138 zero length codes
							j = 11 + this.readBits(7);
						}
						if (i + j > n) {
							this.flushBuffer();
							return 1;
						}
						while ((j--) != 0) {
							ll[i++] = 0;
						}
					}
				} // while

				// Can overwrite tree decode tree as it is not used anymore
				len = this.literalTree.length;
				for (i in 0...len)
					this.literalTree[i] = new HufNode();
				if (this.createTree(this.literalTree, literalCodes, ll, 0) != 0) {
					this.flushBuffer();
					return 1;
				}
				len = this.literalTree.length;
				for (i in 0...len) this.distanceTree[i] = new HufNode();
				var ll2 = new Array();
				for (i in literalCodes...ll.length) ll2[i - literalCodes] = ll[i];
				if (this.createTree(this.distanceTree, distCodes, ll2, 0) != 0) {
					this.flushBuffer();
					return 1;
				}
				// if (this.debug) document.write("<br>literalTree");
				while (true) {
					j = this.decodeValue(this.literalTree);
					if (j >= 256) {        // In C64: if carry set
						var len, dist : Int;
						j -= 256;
						if (j == 0) {
							// EOF
							break;
						}
						j--;
						len = this.readBits(cplext[j]) + cplens[j];

						j = this.decodeValue(this.distanceTree);
						if (cpdext[j] > 8) {
							dist = this.readBits(8);
							dist |= (this.readBits(cpdext[j] - 8) << 8);
						} else {
							dist = this.readBits(cpdext[j]);
						}
						dist += cpdist[j];
						while ((len--) != 0) {
							var c = this.buf32k[(this.bIdx - dist) & 0x7fff];
							this.addBuffer(c);
						}
					} else {
						this.addBuffer(j);
					}
				} // while
			}
		} while (last == 0);
		this.flushBuffer();

		this.byteAlign();
		return 0;
	}
	
	public function unzipFile(name : String) : String {
		this.gunzipLocal();
		for (i in 0...this.unzipped.length) {
			if (this.unzipped[i][1] == name) {
				return this.unzipped[i][0];
			}
		}
		return null;
	}

	public function nextFile() {
		// if (this.debug) alert("NEXTFILE");

		this.outputArr = [];
		this.modeZIP = false;

		var tmp : Array<Int> = [];
		tmp[0] = this.readByte();
		tmp[1] = this.readByte();
		// if (this.debug) alert("type: "+tmp[0]+" "+tmp[1]);

		if (tmp[0] == 0x78 && tmp[1] == 0xda) { //GZIP
			// if (this.debug) alert("GEONExT-GZIP");
			this.deflateLoop();
			// if (this.debug) alert(this.outputArr.join(''));
			this.unzipped[this.files] = [this.outputArr.join(''), "geonext.gxt"];
			this.files++;
		}
		if (tmp[0] == 0x1f && tmp[1] == 0x8b) { //GZIP
			// if (this.debug) alert("GZIP");
			this.skipdir();
			// if (this.debug) alert(this.outputArr.join(''));
			this.unzipped[this.files] = [this.outputArr.join(''), "file"];
			this.files++;
		}
		if (tmp[0] == 0x50 && tmp[1] == 0x4b) { //ZIP
			this.modeZIP = true;
			tmp[2] = this.readByte();
			tmp[3] = this.readByte();
			if (tmp[2] == 0x03 && tmp[3] == 0x04) {
				//MODE_ZIP
				tmp[0] = this.readByte();
				tmp[1] = this.readByte();
				// if (this.debug) alert("ZIP-Version: "+tmp[1]+" "+tmp[0]/10+"."+tmp[0]%10);

				this.gpflags = this.readByte();
				this.gpflags |= (this.readByte() << 8);
				// if (this.debug) alert("gpflags: "+this.gpflags);

				var method = this.readByte();
				method |= (this.readByte() << 8);
				// if (this.debug) alert("method: "+method);

				this.readByte();
				this.readByte();
				this.readByte();
				this.readByte();

	//       var crc = this.readByte();
	//       crc |= (this.readByte()<<8);
	//       crc |= (this.readByte()<<16);
	//       crc |= (this.readByte()<<24);

				var compSize = this.readByte();
				compSize |= (this.readByte() << 8);
				compSize |= (this.readByte() << 16);
				compSize |= (this.readByte() << 24);

				var size = this.readByte();
				size |= (this.readByte() << 8);
				size |= (this.readByte() << 16);
				size |= (this.readByte() << 24);

				// if (this.debug) alert("local CRC: "+crc+"\nlocal Size: "+size+"\nlocal CompSize: "+compSize);

				var filelen : Int = this.readByte();
				filelen |= (this.readByte() << 8);

				var extralen = this.readByte();
				extralen |= (this.readByte() << 8);

				// if (this.debug) alert("filelen "+filelen);
				var i = 0;
				this.nameBuf = [];
				var c : Int;
				while ((filelen--) != 0) {
					c = this.readByte();
					if (String.fromCharCode(c) == "/" || String.fromCharCode(c) == ":") {
						i = 0;
					} else if (i < NAMEMAX - 1) {
						this.nameBuf[i++] = String.fromCharCode(c);
					}
				}
				// if (this.debug) alert("nameBuf: "+this.nameBuf);

				if (this.fileout == null) this.fileout = this.nameBuf;

				i = 0;
				while (i < extralen) {
					c = this.readByte();
					i++;
				}

				// if (size = 0 && this.fileOut.charAt(this.fileout.length-1)=="/"){
				//   //skipdir
				//   // if (this.debug) alert("skipdir");
				// }
				if (method == 8) {
					this.deflateLoop();
					// if (this.debug) alert(this.outputArr.join(''));
					this.unzipped[this.files] = [this.outputArr.join(''), this.nameBuf.join('')];
					this.files++;
				}
				this.skipdir();
			}
		}
	}

	public function skipdir() : Int{
		var tmp : Array<Int> = [];
		var compSize : Int, size : Int, os : Int, i : Int , c : Int;

		if ((this.gpflags & 8) != 0) {
			tmp[0] = this.readByte();
			tmp[1] = this.readByte();
			tmp[2] = this.readByte();
			tmp[3] = this.readByte();

	//     if (tmp[0] == 0x50 && tmp[1] == 0x4b && tmp[2] == 0x07 && tmp[3] == 0x08) {
	//       crc = this.readByte();
	//       crc |= (this.readByte()<<8);
	//       crc |= (this.readByte()<<16);
	//       crc |= (this.readByte()<<24);
	//     } else {
	//       crc = tmp[0] | (tmp[1]<<8) | (tmp[2]<<16) | (tmp[3]<<24);
	//     }

			compSize = this.readByte();
			compSize |= (this.readByte() << 8);
			compSize |= (this.readByte() << 16);
			compSize |= (this.readByte() << 24);

			size = this.readByte();
			size |= (this.readByte() << 8);
			size |= (this.readByte() << 16);
			size |= (this.readByte() << 24);
		}

		if (this.modeZIP) this.nextFile();

		tmp[0] = this.readByte();
		if (tmp[0] != 8) {
			// if (this.debug) alert("Unknown compression method!");
			return 0;
		}

		this.gpflags = this.readByte();
		// if (this.debug && (this.gpflags & ~(0x1f))) alert("Unknown flags set!");

		this.readByte();
		this.readByte();
		this.readByte();
		this.readByte();

		this.readByte();
		os = this.readByte();

		if ((this.gpflags & 4)!= 0) {
			tmp[0] = this.readByte();
			tmp[2] = this.readByte();
			this.len = tmp[0] + 256 * tmp[1];
			// if (this.debug) alert("Extra field size: "+this.len);
			for (i in 0...this.len)
				this.readByte();
		}

		if ((this.gpflags & 8)!=0) {
			i = 0;
			this.nameBuf = [];
			
			while ((c = this.readByte()) != 0) {
				if (String.fromCharCode(c) == "7" || String.fromCharCode(c) == ":")
					i = 0;
				if (i < NAMEMAX - 1)
					this.nameBuf[i++] = String.fromCharCode(c);
			}
			//this.nameBuf[i] = "\0";
			// if (this.debug) alert("original file name: "+this.nameBuf);
		}

		//if ((this.gpflags & 16) != 0) {
			//while (c = this.readByte() != 0) { // FIXME: looks like they read to the end of the stream, should be doable more efficiently
				//FILE COMMENT
			//}
		//}

		if ((this.gpflags & 2) != 0) {
			this.readByte();
			this.readByte();
		}

		this.deflateLoop();

	//   crc = this.readByte();
	//   crc |= (this.readByte()<<8);
	//   crc |= (this.readByte()<<16);
	//   crc |= (this.readByte()<<24);

		size = this.readByte();
		size |= (this.readByte() << 8);
		size |= (this.readByte() << 16);
		size |= (this.readByte() << 24);

		if (this.modeZIP) {
			this.nextFile();
		}
		return 0;
	}
}

class HufNode {
	public var b0 = 0;
	public var b1 = 0;
	public var jumppos : Int = -1;
	public var jump : HufNode;
	
	public function new() {
		
	}
}