package org.mixingloom.managers {
	import mx.events.ModuleEvent;
	import mx.events.RSLEvent;
	import mx.preloaders.Preloader;
	
	import org.mixingloom.SwfContext;
	import org.mixingloom.invocation.InvocationType;
	import org.mixingloom.patcher.IPatcher;
	import org.mixingloom.preloader.watcher.IPatcherApplier;
	
	public interface IPatchManager {

		function createApplier( invocationType:InvocationType, swfContext:SwfContext ):IPatcherApplier;
		function registerPatcher( patcher:IPatcher ):void;
		function set preloader( value:Preloader ):void;
		function set rslItemList( value:Array ):void;
	}
}