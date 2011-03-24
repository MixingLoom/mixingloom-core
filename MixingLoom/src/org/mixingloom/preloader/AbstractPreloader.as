package org.mixingloom.preloader {
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.Timer;
	
	import mx.events.FlexEvent;
	import mx.events.RSLEvent;
	import mx.preloaders.DownloadProgressBar;
	
	import org.as3commons.bytecode.util.SWFSpec;
	import org.mixingloom.SwfContext;
	import org.mixingloom.SwfTag;
	import org.mixingloom.byteLoader.ModifiedByteLoader;
	import org.mixingloom.invocation.InvocationType;
	import org.mixingloom.patcher.IPatcher;
	import org.mixingloom.preloader.watcher.IPatcherApplier;
	import org.mixingloom.preloader.watcher.PatcherApplierImpl;
	
	public class AbstractPreloader extends DownloadProgressBar implements IPatchNotifier {
		private var loader:Sprite;
		private var applier:IPatcherApplier;
		private var context:SwfContext = new SwfContext();
		
		override public function set preloader(value:Sprite):void
		{
			super.preloader = value;
			loader = value;
			
			//Remove lower priority hit
			loader.removeEventListener(RSLEvent.RSL_COMPLETE, rslCompleteHandler);
			
			//add higher priority hit
			loader.addEventListener(RSLEvent.RSL_COMPLETE, rslCompleteHandler, false, 1000 );
			
			loader.addEventListener(FlexEvent.PRELOADER_DOC_FRAME_READY, handleFrame2Ready, false, 1000 );
			//loader.addEventListener(RSLEvent.RSL_COMPLETE, this.rslCompleteHandler);
			//loader.addEventListener(RSLEvent.RSL_PROGRESS, this.rslProgressHandler);
		}

		override protected function rslCompleteHandler( event:RSLEvent ):void {
			super.rslCompleteHandler( event );
			//Stops the SystemManager from dealing with RSLs until we are ready
			event.stopImmediatePropagation();
			
			/*			var context:SwfContext = new SwfContext();
			context.swfBytes = event.loaderInfo.bytes;
			processPatchers( new InvocationType( InvocationType.RSL, event.url ), context  );
			
			event.currentTarget.dispatchEvent( event.clone() );*/
		}

		private function handleFrame2Ready( event:FlexEvent ):void {
			
			//Stops the playhead from moving to Frame2
			event.stopImmediatePropagation();

			loader.removeEventListener(FlexEvent.PRELOADER_DOC_FRAME_READY, handleFrame2Ready );

			context.swfBytes = loaderInfo.bytes;
			var uncompressedSwf:ByteArray = uncompressSwf(context.swfBytes);
			
			// we can only modify frame 2 tags
			context.swfTags = getFrameTwoTags(uncompressedSwf);

			processPatchers( new InvocationType( InvocationType.FRAME2 ), context  );
		}
		

		protected function processPatchers( invocationType:InvocationType, swfContext:SwfContext ):void {
			applier.applyPatches( invocationType, swfContext );
		}

		protected function registerPatcher( patcher:IPatcher ):void {
			applier.registerPatcher( patcher );
		}
		
		public function allPatchesComplete():void {
			var byteLoader:ModifiedByteLoader = new ModifiedByteLoader();
			byteLoader.notifier = this;
			byteLoader.applyModificiations( context );
		}
		
		public function byteModificationComplete():void {
			loader.dispatchEvent( new FlexEvent( FlexEvent.PRELOADER_DOC_FRAME_READY ) );
		}
		
		protected function setupPatchers():void {
			
		}

		override public function initialize():void {
			super.initialize();
			
			setupPatchers();
		}

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
		
		public function getFrameTwoTags(byteArray:ByteArray):Vector.<SwfTag>
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
			
			return allSwfTags[2];
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
				swfTags.push(readTag(originalBytes))
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

		public function AbstractPreloader() {
			super();
			
			applier = new PatcherApplierImpl();
			applier.notifier = this;
		}
	}
}