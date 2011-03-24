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
		private var _notifier:IPatchNotifier;
		private var context:SwfContext;
		private var type:InvocationType;

		public function set notifier( value:IPatchNotifier ):void {
			this._notifier = value;
		}
		
		public function applyPatches( invocationType:InvocationType, context:SwfContext ):void {
			
			trace( invocationType.type + ' ' + (invocationType.url?invocationType.url.url:'' ) );
			this.context = context;
			this.type = invocationType;

			applyingPatch = true;

			startNextPatch();
		}
		
		private function startNextPatch():void {
			if ( !allPatchesComplete ) {
				var patch:IPatcher = patchers.shift();
				
				patch.apply( type, context );
			} else {
				_notifier.allPatchesComplete();
			}
		}
		
		public function registerPatcher( patcher:IPatcher ):void {
			patcher.applier = this;
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