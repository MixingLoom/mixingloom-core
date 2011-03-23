package org.mixingloom.invocation {
	import flash.net.URLRequest;

	public class InvocationType {

		public static const FRAME2:String = "frame2";
		public static const RSL:String = "rsl";
		public static const MODULE:String = "module";

		private var _type:String;
		private var _url:URLRequest;
		
		public function get type():String {
			return _type;
		}

		public function get uri():URLRequest {
			return _url;
		}

		public function InvocationType( type:String, url:URLRequest=null ) {
			this._type = type;
			this._url = url;
		}
	}
}
