package org.mixingloom.preloader.watcher {
	import org.mixingloom.patcher.IPatcher;
	import org.mixingloom.preloader.IPatchNotifier;

	public interface IPatcherApplier {
		function registerPatcher( patcher:IPatcher ):void;
		function startPatching( patcher:IPatcher ):void;
		function completePatching( patcher:IPatcher ):void;
		
		function applyPatches( notifier:IPatchNotifier ):void;
		
		function get allPatchesComplete():Boolean;
	}
}