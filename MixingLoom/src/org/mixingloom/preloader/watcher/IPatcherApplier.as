package org.mixingloom.preloader.watcher {
import flash.system.LoaderContext;

import org.mixingloom.SwfContext;
	import org.mixingloom.invocation.InvocationType;
	import org.mixingloom.patcher.IPatcher;

	public interface IPatcherApplier {
		function apply():void;
		
		function set patchers( patchers:Vector.<IPatcher> ):void;
    function set invocationType(value:InvocationType):void;
		function set swfContext(value:SwfContext):void;
    function set loaderContext(loaderContext:LoaderContext):void;

		function setCallBack(value:Function):void;
  }
}