package preloader {
	import org.mixingloom.preloader.AbstractPreloader;
	import org.mixingloom.preloader.IPatchNotifier;
	
	import patcher.SampleAsyncPatcher;
	import patcher.SamplePatcher;
	
	public class MyPreloader extends AbstractPreloader {
		
		override protected function setupPatchers():void {
			super.setupPatchers();
			
			registerPatcher( new SamplePatcher() );
			registerPatcher( new SampleAsyncPatcher( 5000 ) );	
		}
		
		public function MyPreloader() {
			super();
		}
	}
}