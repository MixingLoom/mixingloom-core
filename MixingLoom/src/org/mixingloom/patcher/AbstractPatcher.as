package org.mixingloom.patcher {
	import org.mixingloom.SwfContext;
	import org.mixingloom.invocation.InvocationType;
	import org.mixingloom.preloader.watcher.IPatcherApplier;
	
	public class AbstractPatcher implements IPatcher {
		private var _applier:IPatcherApplier;
				
		public function get applier():IPatcherApplier {
			return _applier;
		}
		
		public function set applier(value:IPatcherApplier):void {
			_applier = value;
		}
		
		public function apply( invocationType:InvocationType, swfContext:SwfContext ):void {
		}
		
		public function AbstractPatcher() {
		}
		
	}
}