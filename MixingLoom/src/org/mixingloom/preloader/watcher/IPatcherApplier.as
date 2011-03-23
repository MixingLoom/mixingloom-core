package org.mixingloom.preloader.watcher {
	import flash.utils.ByteArray;
	
	import org.mixingloom.invocation.InvocationType;
	import org.mixingloom.patcher.IPatcher;
	import org.mixingloom.preloader.IPatchNotifier;

	public interface IPatcherApplier {
		function registerPatcher( patcher:IPatcher ):void;
		function startPatching( patcher:IPatcher ):void;
		function completePatching( patcher:IPatcher ):void;
		
		function applyPatches( notifier:IPatchNotifier, bytes:ByteArray, invocationType:InvocationType ):void;
		
		function get allPatchesComplete():Boolean;
	}
}