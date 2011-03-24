package preloader {
	import org.mixingloom.preloader.AbstractPreloader;
	import org.mixingloom.preloader.IPatchNotifier;
	
	import patcher.RevealPrivatesPatcher;
	import patcher.SampleAsyncPatcher;
	import patcher.SamplePatcher;
	
	//[Frame(factoryClass="systemManager.LoomManager")]
	public class MyPreloader extends AbstractPreloader {
		
		override protected function setupPatchers():void {
			super.setupPatchers();
			
			//registerPatcher( new SamplePatcher() );
			//registerPatcher( new SampleAsyncPatcher( 5000 ) );
			registerPatcher( new RevealPrivatesPatcher("blah/Foo", "getPrivateBar") );
		}
		
		public function MyPreloader() {
			super();
		}
	}
}