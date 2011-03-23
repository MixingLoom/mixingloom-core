package org.mixingloom.patcher {
import org.mixingloom.SwfContext;
import org.mixingloom.invocation.InvocationType;
	import org.mixingloom.preloader.watcher.IPatcherApplier;

	public interface IPatcher {
		function get applier():IPatcherApplier;
		function set applier( value:IPatcherApplier ):void;

		function apply( invocationType:InvocationType, swfContext:SwfContext ):void;
	}
}