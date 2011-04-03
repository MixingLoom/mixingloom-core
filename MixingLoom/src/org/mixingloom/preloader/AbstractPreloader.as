package org.mixingloom.preloader {
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.preloaders.DownloadProgressBar;
	import mx.preloaders.Preloader;
	
	import org.mixingloom.managers.IPatchManager;
	import org.mixingloom.managers.IPatchManagerClient;
	import org.mixingloom.managers.PatchManager;
	import org.mixingloom.patcher.IPatcher;
	
	public class AbstractPreloader extends DownloadProgressBar implements IPatchManagerClient {
		private var _patchManager:IPatchManager;
		protected var timer:Timer;

		public function get patchManager():IPatchManager {
			return _patchManager;
		}

		public function set patchManager( value:IPatchManager ):void {
			if ( _patchManager !== value ) {
				if ( _patchManager ) {
					//Clean up the old one
					_patchManager.cleanUpManager();
				}

				_patchManager = value;
	
				//I hate this, but due to the way the Flex preloader is coded,
				//we need to wait a frame to make this work in all cases
				startPatcherSetup();
			}
		}

		override public function set preloader(value:Sprite):void {
			//In a preloader only scenario, we will get here and need to make our
			//own patchmanager
			if ( !_patchManager ) {
				patchManager = createPatchManager();
			}
			
			if ( patchManager.preloader !== value ) {
				patchManager.preloader = value as Preloader; 
			}

			super.preloader = value;
		}
			
		/** Only called when a patch manager is not provided.. generally when we don't
		 *  care about RSLs and are in preloader only mode **/
		protected function createPatchManager():IPatchManager {
			var pm:IPatchManager = new PatchManager();
			return new PatchManager();
		}
		
		protected function startPatcherSetup():void {
			if ( !timer || !timer.running ) {
				timer = new Timer( 10, 1 );
				timer.addEventListener( TimerEvent.TIMER_COMPLETE, handleTimerComplete );
				timer.start();
			}
		}
		
		protected function handleTimerComplete( event:TimerEvent ):void {
			timer.removeEventListener( TimerEvent.TIMER_COMPLETE, handleTimerComplete );

			setupPatchers( patchManager );
		}

		protected function setupPatchers( manager:IPatchManager ):void {
		}

		public function AbstractPreloader() {
			super();
		}
	}
}