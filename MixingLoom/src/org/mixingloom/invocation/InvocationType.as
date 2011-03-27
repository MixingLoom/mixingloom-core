package org.mixingloom.invocation {
	import flash.net.URLRequest;

	public class InvocationType {

    public static const INIT:String = "init";
    public static const FRAME1:String = "frame1";
		public static const FRAME2:String = "frame2";
		public static const RSL:String = "rsl";
		public static const MODULE:String = "module";

		private var _type:String;
		private var _url:String;
		
		public function get type():String {
			return _type;
		}

		public function get url():String {
			return _url;
		}

		public function InvocationType( type:String, url:String=null ) {
			this._type = type;
			this._url = url;
		}
	}
}
