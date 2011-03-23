package org.mixingloom.invocation {
	public class InvocationType {

		public static const FRAME2:String = "frame2";
		public static const RSL:String = "rsl";
		public static const MODULE:String = "module";

		private var _type:String;
		private var _uri:String;
		
		public function get type():String {
			return _type;
		}

		public function get uri():String {
			return _uri;
		}

		public function InvocationType( type:String, uri:String=null ) {
			this._type = type;
			this._uri = uri;
		}
	}
}
