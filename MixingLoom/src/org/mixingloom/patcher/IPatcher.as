package org.mixingloom.patcher {
import org.mixingloom.SwfContext;
import org.mixingloom.invocation.InvocationType;
	import org.mixingloom.preloader.watcher.IPatcherApplier;

	public interface IPatcher {
		function get swfContext():SwfContext;
		function set swfContext( context:SwfContext ):void;

		function apply( applier:IPatcherApplier, invocationType:InvocationType ):void;
	}
}