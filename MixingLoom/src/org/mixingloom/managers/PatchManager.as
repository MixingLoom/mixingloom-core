package org.mixingloom.managers {
	import mx.events.FlexEvent;
	import mx.events.RSLEvent;
	import mx.preloaders.Preloader;
	
	import org.mixingloom.SwfContext;
	import org.mixingloom.byteCode.ByteParser;
	import org.mixingloom.byteCode.ModifiedByteLoader;
	import org.mixingloom.core.LoomCrossDomainRSLItem;
	import org.mixingloom.invocation.InvocationType;
	import org.mixingloom.patcher.IPatcher;
	import org.mixingloom.preloader.watcher.IPatcherApplier;
	import org.mixingloom.preloader.watcher.PatcherApplierImpl;
	
	public class PatchManager implements IPatchManager {
		private var patchers:Vector.<IPatcher>;
		private var _preloader:Preloader;
		private var _rslItemList:Array;
		private var frame2Context:SwfContext;
		
		public function createApplier( invocationType:InvocationType, swfContext:SwfContext ):IPatcherApplier {
			var applier:IPatcherApplier = new PatcherApplierImpl();
			applier.patchers = patchers.slice();
			applier.invocationType = invocationType;
			applier.swfContext = swfContext;
			return applier;
		}
		
		public function registerPatcher( patcher:IPatcher ):void {
			patchers.push( patcher );
		}
		
		public function set rslItemList( value:Array ):void {
			_rslItemList = value.slice();
			
		}

		public function get rslsComplete():Boolean {
			return ( !_rslItemList || ( _rslItemList.length == 0 ) );
		}

		public function set preloader( value:Preloader ):void {

			if ( _preloader ) {
				_preloader.removeEventListener( FlexEvent.PRELOADER_DOC_FRAME_READY, 
					handleFrame2Ready, 
					false );

				_preloader.removeEventListener( RSLEvent.RSL_COMPLETE, 
					handleRSLComplete, 
					false );
			}
			
			_preloader = value;

			if ( _preloader ) {
				_preloader.addEventListener( FlexEvent.PRELOADER_DOC_FRAME_READY, 
										   handleFrame2Ready, 
										   false, 
										   1000 );

				_preloader.addEventListener( RSLEvent.RSL_COMPLETE, 
					handleRSLComplete, 
					false,
					1000 );
			}
		}
		
		private function handleFrame2Ready( event:FlexEvent ):void {
			var parser:ByteParser = new ByteParser();
			frame2Context = parser.createSwfContext( _preloader.loaderInfo.bytes );

			//We stop the systemManager from moving forward into frame 2
			event.stopImmediatePropagation();

			_preloader.removeEventListener( FlexEvent.PRELOADER_DOC_FRAME_READY, 
				handleFrame2Ready, 
				false );

			var applier:IPatcherApplier = createApplier( new InvocationType( InvocationType.FRAME2, null ), frame2Context );
			applier.setCallBack( checkFrameContinue );
			applier.apply();
		}
		
		private function removeRSLFromList( url:String ):void {
			var rsl:LoomCrossDomainRSLItem;
			for ( var i:int=0; i<_rslItemList.length; i++ ) {
				rsl = _rslItemList[ i ] as LoomCrossDomainRSLItem;
				if ( rsl.equalURL( url ) ) {
					_rslItemList.splice( i, 1 );
					return;
				}
			}
		}
		
		private function handleRSLComplete( event:RSLEvent ):void {
			removeRSLFromList( event.url.url );
			checkFrameContinue();
		}
		
		private function checkFrameContinue():void {
			if ( rslsComplete ) {
				var modifier:ModifiedByteLoader = new ModifiedByteLoader();
				modifier.setCallBack( moveToFrame2 ); 
				modifier.applyModificiations( frame2Context );
			}
		}
		
		private function moveToFrame2():void {
			//we allow the system manager to move to frame 2
			_preloader.dispatchEvent( new FlexEvent( FlexEvent.PRELOADER_DOC_FRAME_READY ) );
		}
		
		public function PatchManager() {
			patchers = new Vector.<IPatcher>();
		}
	}
}
