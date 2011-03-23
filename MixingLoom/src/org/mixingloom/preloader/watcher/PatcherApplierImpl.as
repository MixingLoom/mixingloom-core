package org.mixingloom.preloader.watcher {
	import flash.utils.Dictionary;
	
	import org.mixingloom.patcher.IPatcher;
	import org.mixingloom.preloader.IPatchNotifier;

	public class PatcherApplierImpl implements IPatcherApplier {

		private var activePatchers:Dictionary = new Dictionary();
		private var patchers:Vector.<IPatcher>;
		private var applyingPatch:Boolean = false;
		private var notifier:IPatchNotifier;

		public function applyPatches( notifier:IPatchNotifier ):void {
			
			if ( applyingPatch ) {
				throw new Error( "What the fuck?" );
			}

			this.notifier = notifier;

			applyingPatch = true;

			startNextPatch();
		}
		
		private function startNextPatch():void {
			if ( !allPatchesComplete ) {
				var patch:IPatcher = patchers.shift();
				patch.apply( this, null );
			} else {
				notifier.allPatchesComplete();
			}
		}
		
		public function registerPatcher( patcher:IPatcher ):void {
			patchers.push( patcher );
		}
		
		public function startPatching( patcher:IPatcher ):void {
			activePatchers[ patcher ] = true;
		}

		public function completePatching( patcher:IPatcher ):void {
			delete activePatchers[ patcher ];
			
			startNextPatch();
		}
		
		public function get allPatchesComplete():Boolean {
			return ( patchers.length == 0 );
		}

		public function PatcherApplierImpl() {
			patchers = new Vector.<IPatcher>();
		}
	}
}