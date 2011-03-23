package org.mixingloom.patcher {
	import org.mixingloom.invocation.InvocationType;
	import org.mixingloom.preloader.watcher.IPatcherApplier;

	public interface IPatcher {
		function get swfContext():*;
		function set swfContext( context:* ):void;

		function apply( applier:IPatcherApplier, invocationType:InvocationType ):void;
	}
}