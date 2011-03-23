package patcher {
import org.mixingloom.SwfContext;
import org.mixingloom.invocation.InvocationType;
import org.mixingloom.patcher.AbstractPatcher;
import org.mixingloom.patcher.IPatcher;
import org.mixingloom.preloader.watcher.IPatcherApplier;

	public class SamplePatcher extends AbstractPatcher {

		override public function apply( invocationType:InvocationType, swfContext:SwfContext ):void {
			applier.startPatching( this );
			applier.completePatching( this );
		}
		
		public function SamplePatcher() {
		}
	}
}