package systemManager
{
	import mx.core.mx_internal;
	import mx.managers.SystemManager;
	
	use namespace mx_internal;

	public class LoomManager extends SystemManager
	{
		override mx_internal function initialize():void {
			var info:Object = info();
			info[ "cdRsls" ] = [];
			info[ "rsls" ] = [];

			super.initialize();
		}
			
		public function LoomManager()
		{
			super();
		}
	}
}