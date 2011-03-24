package org.mixingloom.byteLoader {
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import org.mixingloom.SwfContext;
	import org.mixingloom.SwfTag;
	import org.mixingloom.preloader.IPatchNotifier;

	public class ModifiedByteLoader {
		private var _notifier:IPatchNotifier;

		public function set notifier( value:IPatchNotifier ):void {
			this._notifier = value;
		}
		
		public function applyModificiations( swfContext:SwfContext ):void {
			var swfTags:Vector.<SwfTag> = swfContext.swfTags;
			var numTagsModified:uint = 0;
			
			var modifiedBytes:ByteArray = new ByteArray();
			modifiedBytes.endian = Endian.LITTLE_ENDIAN;
			
			for each (var swfHeaderByte:int in [0x46, 0x57, 0x53, 0x0a, 0xff, 0xff, 0xff, 0xff, 0x70, 0x00, 0x0b, 0xb8, 0x00, 0x00, 0xbb, 0x80, 0x00, 0x18, 0x01, 0x00])
			{
				modifiedBytes.writeByte(swfHeaderByte);
			}
			
			// write the file attributes
			for each (var fileAttrByte:int in [0x44, 0x11, 0x08, 0x00, 0x00, 0x00])
			{
				modifiedBytes.writeByte(fileAttrByte);
			}
			
			for each (var swfTag:SwfTag in swfTags)
			{
				//trace('writing tag ' + swfTag.name);
				//if (swfTag.modified)
				//{
				numTagsModified++;
				modifiedBytes.writeBytes(swfTag.recordHeader);
				modifiedBytes.writeBytes(swfTag.tagBody);
				//}
			}
			
			if (numTagsModified < 1)
			{
				// just finish
				_notifier.byteModificationComplete();
				return;
			}
			
			modifiedBytes.writeByte(0x40);
			modifiedBytes.writeByte(0);
			
			// write the swf footer
			modifiedBytes.writeByte(0);
			modifiedBytes.writeByte(0);
			
			// set the length of the total SWF
			modifiedBytes.position = 4;
			modifiedBytes.writeUnsignedInt(modifiedBytes.length);
			
			modifiedBytes.position = 0;
			
			trace('modifiedBytes.length = ' + modifiedBytes.length);
			
			var loaderContext:LoaderContext = new LoaderContext();
			loaderContext.applicationDomain = ApplicationDomain.currentDomain;
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleLoaderComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleLoaderError);
			loader.loadBytes(modifiedBytes, loaderContext);
		}
		
		private function handleLoaderComplete(event:Event):void
		{
			_notifier.byteModificationComplete();
		}
		
		private function handleLoaderError(event:IOErrorEvent):void
		{
			_notifier.byteModificationComplete();
		}
		
		public function ModifiedByteLoader() {
		}
	}
}