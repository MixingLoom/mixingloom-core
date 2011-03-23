package patcher {

	import org.mixingloom.invocation.InvocationType;
	import org.mixingloom.patcher.IPatcher;
	import org.mixingloom.preloader.watcher.IPatcherApplier;

	public class SamplePatcher implements IPatcher {
		public function get swfContext():* {
			return null;	
		}

		public function set swfContext( context:* ):void {
			
		}
		
		public function apply( applier:IPatcherApplier, invocationType:InvocationType ):void {
			applier.startPatching( this );
			applier.completePatching( this );
		}
		
		public function SamplePatcher() {
		}
	}
}