package org.mixingloom.preloader {
	import mx.preloaders.DownloadProgressBar;
	
	import org.mixingloom.managers.IPatchManager;
	import org.mixingloom.managers.IPatchManagerClient;
	import org.mixingloom.patcher.IPatcher;
	
	public class AbstractPreloader extends DownloadProgressBar implements IPatchManagerClient {
		private var _patchManager:IPatchManager;

		public function get patchManager():IPatchManager {
			return _patchManager;
		}

		public function set patchManager(value:IPatchManager):void {
			_patchManager = value;
			
			setupPatchers();
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