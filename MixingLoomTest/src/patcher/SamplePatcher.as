package patcher {
import org.mixingloom.SwfContext;
import org.mixingloom.invocation.InvocationType;
	import org.mixingloom.patcher.IPatcher;
	import org.mixingloom.preloader.watcher.IPatcherApplier;

	public class SamplePatcher implements IPatcher {
		public function get swfContext():SwfContext {
			return null;	
		}

		public function set swfContext( context:SwfContext ):void {
			
		}
		
		public function apply( applier:IPatcherApplier, invocationType:InvocationType ):void {
			applier.startPatching( this );
			applier.completePatching( this );
		}
		
		public function SamplePatcher() {
		}
	}
}