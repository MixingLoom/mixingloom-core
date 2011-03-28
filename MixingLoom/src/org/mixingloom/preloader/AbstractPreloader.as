package org.mixingloom.preloader {
	import flash.display.Sprite;
	
	import mx.preloaders.DownloadProgressBar;
	import mx.preloaders.Preloader;
	
	import org.mixingloom.managers.IPatchManager;
	import org.mixingloom.managers.IPatchManagerClient;
	import org.mixingloom.managers.PatchManager;
	import org.mixingloom.patcher.IPatcher;
	
	public class AbstractPreloader extends DownloadProgressBar implements IPatchManagerClient {
		private var _patchManager:IPatchManager;

		public function get patchManager():IPatchManager {
			if ( !_patchManager ) {
				patchManager = createPatchManager();
			}
			return _patchManager;
		}

		public function set patchManager(value:IPatchManager):void {
			_patchManager = value;
			
			setupPatchers();
		}

		override public function set preloader(value:Sprite):void {
			if ( !patchManager.preloader ) {
				patchManager.preloader = value as Preloader; 
			}

			super.preloader = value;
		}
			
		protected function createPatchManager():IPatchManager {
			var pm:IPatchManager = new PatchManager();
			return new PatchManager();
		}

		protected function registerPatcher( patcher:IPatcher ):void {
			patchManager.registerPatcher( patcher );
		}

		protected function setupPatchers():void {
		}


		public function AbstractPreloader() {
			super();
		}
	}
}