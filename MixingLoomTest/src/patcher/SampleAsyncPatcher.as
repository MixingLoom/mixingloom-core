package patcher
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;

import org.mixingloom.SwfContext;
import org.mixingloom.invocation.InvocationType;
	import org.mixingloom.patcher.IPatcher;
	import org.mixingloom.preloader.watcher.IPatcherApplier;
	
	public class SampleAsyncPatcher implements IPatcher
	{
		private var timer:Timer;
		private var applier:IPatcherApplier;

		public function SampleAsyncPatcher( delay:int )
		{
			timer = new Timer( delay, 1 );
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, handleTimerComplete );
		}
		
		public function get swfContext():SwfContext
		{
			return null;
		}
		
		public function set swfContext(context:SwfContext):void
		{
		}
		
		private function handleTimerComplete( event:TimerEvent ):void {
			applier.completePatching( this );
		}

		public function apply(applier:IPatcherApplier, invocationType:InvocationType):void
		{
			this.applier = applier;

			applier.startPatching( this );
			
			timer.reset();
			timer.start();
		}
	}
}