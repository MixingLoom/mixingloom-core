package org.mixingloom.preloader.watcher {
	import org.mixingloom.SwfContext;
	import org.mixingloom.invocation.InvocationType;
	import org.mixingloom.patcher.IPatcher;

	public class PatcherApplierImpl implements IPatcherApplier {

		private var callBack:Function;
		private var callBackArgs:Array;

		private var _patchers:Vector.<IPatcher>;
		private var _swfContext:SwfContext;
		private var _invocationType:InvocationType;

		public function get allPatchesComplete():Boolean {
			return ( _patchers.length == 0 );
		}

		public function get invocationType():InvocationType
		{
			return _invocationType;
		}

		public function set invocationType(value:InvocationType):void
		{
			_invocationType = value;
		}

		public function get swfContext():SwfContext
		{
			return _swfContext;
		}

		public function set swfContext(value:SwfContext):void
		{
			_swfContext = value;
		}

		public function set patchers( value:Vector.<IPatcher> ):void {
			_patchers = value.slice();
		}
		
		public function apply():void {
			
			trace( invocationType.type + ' ' + invocationType.url  );
			//applyingPatch = true;
			startNextPatch();
		}

		public function setCallBack( value:Function, args:Array=null ):void {
			this.callBack = value;
			this.callBackArgs = args;
		}

		protected function invokeCallBack():void {
			if ( callBack != null ) {
				callBack.apply( null, callBackArgs );
			}
		}

		private function startNextPatch():void {
			if ( !allPatchesComplete ) {
				var patcher:IPatcher = _patchers.shift();
				patcher.setCallBack( handleComplete, [patcher] );
				patcher.apply( invocationType, swfContext );
			} else {
				invokeCallBack();
			}
		}
		
		private function handleComplete( patcher:IPatcher ):void {
			//clean up
			patcher.setCallBack( null );

			startNextPatch();
		}

		public function PatcherApplierImpl() {
			patchers = new Vector.<IPatcher>();
		}
	}
}