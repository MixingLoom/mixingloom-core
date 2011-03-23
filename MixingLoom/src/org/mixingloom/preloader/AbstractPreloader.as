package org.mixingloom.preloader {
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import mx.events.FlexEvent;
	import mx.events.RSLEvent;
	import mx.preloaders.DownloadProgressBar;
	
	import org.mixingloom.SwfContext;
	import org.mixingloom.invocation.InvocationType;
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
			
			var context:SwfContext = new SwfContext();
			context.swfBytes = event.loaderInfo.bytes;
			processPatchers( new InvocationType( InvocationType.RSL, event.url ), context  );
		}

		private function handleFrame2Ready( event:FlexEvent ):void {
			
			//Stops the playhead from moving to Frame2
			event.stopImmediatePropagation();

			loader.removeEventListener(FlexEvent.PRELOADER_DOC_FRAME_READY, handleFrame2Ready );

			var context:SwfContext = new SwfContext();
			context.swfBytes = loaderInfo.bytes;

			processPatchers( new InvocationType( InvocationType.FRAME2 ), context  );
		}
		

		protected function processPatchers( invocationType:InvocationType, swfContext:SwfContext ):void {
			applier.applyPatches( invocationType, swfContext );
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
			applier.notifier = this;
		}
	}
}