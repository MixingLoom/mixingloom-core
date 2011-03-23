package org.mixingloom.preloader {
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import mx.events.FlexEvent;
	import mx.preloaders.DownloadProgressBar;
	
	import org.mixingloom.patcher.IPatcher;
	import org.mixingloom.preloader.watcher.IPatcherApplier;
	import org.mixingloom.preloader.watcher.PatcherApplierImpl;
	
	public class AbstractPreloader extends DownloadProgressBar implements IPatchNotifier {
		private var loader:Sprite;
		private var applier:IPatcherApplier;
		
		override public function set preloader(value:Sprite):void
		{
			super.preloader = value;
			loader = value;
			
			loader.addEventListener(FlexEvent.PRELOADER_DOC_FRAME_READY, handleFrame2Ready, false, 1000 );
		}
		
		private function handleFrame2Ready( event:FlexEvent ):void {
			
			//Stops the playhead from moving to Frame2
			event.stopImmediatePropagation();

			loader.removeEventListener(FlexEvent.PRELOADER_DOC_FRAME_READY, handleFrame2Ready );

			processPatchers( loaderInfo.bytes );
		}
		

		protected function processPatchers( bytes:ByteArray ):void {
			applier.applyPatches( this, bytes, null );
		}

		protected function registerPatcher( patcher:IPatcher ):void {
			applier.registerPatcher( patcher );
		}
		
		public function allPatchesComplete():void {
			loader.dispatchEvent( new FlexEvent( FlexEvent.PRELOADER_DOC_FRAME_READY ) );
		}
		
		protected function setupPatchers():void {
			
		}

		override public function initialize():void {
			super.initialize();

			setupPatchers();
		}
			
		public function AbstractPreloader() {
			super();
			
			applier = new PatcherApplierImpl();
		}
	}
}