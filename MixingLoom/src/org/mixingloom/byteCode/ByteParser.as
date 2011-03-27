package org.mixingloom.byteCode {
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import org.as3commons.bytecode.util.SWFSpec;
	import org.mixingloom.SwfContext;
	import org.mixingloom.SwfTag;

	public class ByteParser {
		
		public function uncompressSwf(input:ByteArray):ByteArray
		{
			var output:ByteArray;
			
			if (input.readByte() == 0x43)
			{
				var swfGuts:ByteArray = new ByteArray();
				input.position = 0;
				swfGuts.writeBytes(input, 8);
				swfGuts.position = 0;
				swfGuts.uncompress();
				
				output = new ByteArray();
				output.endian = Endian.LITTLE_ENDIAN;
				output.writeByte(0x46);
				output.writeByte(0x57);
				output.writeByte(0x53);
				output.writeByte(0x0a);
				output.writeUnsignedInt(swfGuts.length + 8);
				output.writeBytes(swfGuts);
			}
			else
			{
				output = input;
				output.endian = Endian.LITTLE_ENDIAN;
			}
			output.position = 0;
			
			return output;
		}

    public function getFrameOneTags(byteArray:ByteArray):Vector.<SwfTag>
		{
			var allSwfTags:Object = getFrameTags(byteArray);

			return allSwfTags[1];
		}

		public function getFrameTwoTags(byteArray:ByteArray):Vector.<SwfTag>
		{
			var allSwfTags:Object = getFrameTags(byteArray);
			
			return allSwfTags[2];
		}

    public function getFrameTags(byteArray:ByteArray):Object
		{
			var allSwfTags:Object = new Object();
			var currentFrame:uint = 0;

			for each (var swfTag:SwfTag in getAllSwfTags(byteArray))
			{
				if (swfTag.type == 43)
				{
					currentFrame++;
				}

				if (allSwfTags[currentFrame] == undefined)
				{
					allSwfTags[currentFrame] = new Vector.<SwfTag>();
				}

				(allSwfTags[currentFrame]).push(swfTag);
			}

			return allSwfTags;
		}
		
		public function getAllSwfTags(originalBytes:ByteArray):Vector.<SwfTag>
		{
			var swfTags:Vector.<SwfTag> = new Vector.<SwfTag>();
			
			// skip the header
			originalBytes.position = 8;
			
			// read framesize
			var fsByte:uint = originalBytes.readUnsignedByte();
			// it's really only 5 bits
			fsByte >>>= 3;
			
			// there are 4 of them
			var fsBits:uint = fsByte * 4;
			
			// we already read 3 extra bits
			fsBits -= 3;
			
			// number of additional bytes to move to get past the framesize
			var fsBytes:uint = Math.ceil(fsBits / 8);
			
			originalBytes.position += fsBytes;
			
			// move another 4 bytes past the frame rate and frame count
			originalBytes.position += 4;
			
			// read the tags
			while (originalBytes.position < (originalBytes.length - 2))
			{
        var swfTag:SwfTag = readTag(originalBytes);

        // exclude the file attributes
        if (swfTag.type != 69)
        {
				  swfTags.push(swfTag);
        }
			}
			
			originalBytes.position = 0;
			
			return swfTags;
		}
		
		public function readTag(originalBytes:ByteArray):SwfTag
		{
			var swfTag:SwfTag = new SwfTag();
			
			// read the record header
			var tagCodeAndLength:uint = originalBytes.readUnsignedShort();
			swfTag.recordHeader.writeShort(tagCodeAndLength);
			swfTag.type = tagCodeAndLength >> 6;
			swfTag.tagLengthExcludingRecordHeader = tagCodeAndLength & 0x3f;
			if (swfTag.tagLengthExcludingRecordHeader == 0x3f)
			{
				swfTag.tagLengthExcludingRecordHeader = originalBytes.readUnsignedInt();
				swfTag.recordHeader.writeUnsignedInt(swfTag.tagLengthExcludingRecordHeader);
			}
			swfTag.tagBody = new ByteArray();
			if (swfTag.tagLengthExcludingRecordHeader > 0)
			{
				originalBytes.readBytes(swfTag.tagBody, 0, swfTag.tagLengthExcludingRecordHeader);
			}
			
			//trace('type = ' + swfTag.type);
			//trace('tagLengthExcludingRecordHeader = ' + swfTag.tagLengthExcludingRecordHeader);
			//trace(HexDump.dumpHex(swfTag.tagBody));
			
			if (swfTag.type == 82)
			{
				// skip the flags
				swfTag.tagBody.position += 4;
				
				swfTag.name = SWFSpec.readString(swfTag.tagBody);
				
				swfTag.tagBody.position = 0;
			}
			
			return swfTag;
		}
		
		public function ByteParser() {
      super();
		}
	}
}