package org.mixingloom.preloader.watcher {
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import org.mixingloom.SwfContext;
	import org.mixingloom.invocation.InvocationType;
	import org.mixingloom.patcher.IPatcher;
	import org.mixingloom.preloader.IPatchNotifier;

	public class PatcherApplierImpl implements IPatcherApplier {

		private var activePatchers:Dictionary = new Dictionary();
		private var patchers:Vector.<IPatcher>;
		private var applyingPatch:Boolean = false;
		private var notifier:IPatchNotifier;
		private var bytes:ByteArray;
		private var type:InvocationType;

		public function applyPatches( notifier:IPatchNotifier, bytes:ByteArray, invocationType:InvocationType ):void {
			
			if ( applyingPatch ) {
				throw new Error( "What the fuck?" );
			}

			this.notifier = notifier;
			this.bytes = bytes;
			this.type = type;

			applyingPatch = true;

			startNextPatch();
		}
		
		private function startNextPatch():void {
			if ( !allPatchesComplete ) {
				var patch:IPatcher = patchers.shift();
				var context:SwfContext = new SwfContext();
				context.swfBytes = bytes;
				patch.swfContext = context;
				patch.apply( this, type );
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