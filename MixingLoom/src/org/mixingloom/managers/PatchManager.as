package org.mixingloom.managers {
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import mx.events.FlexEvent;
	import mx.events.RSLEvent;
	import mx.preloaders.Preloader;
	
	import org.mixingloom.SwfContext;
	import org.mixingloom.SwfTag;
	import org.mixingloom.byteCode.ByteParser;
	import org.mixingloom.core.LoomCrossDomainRSLItem;
	import org.mixingloom.invocation.InvocationType;
	import org.mixingloom.patcher.IPatcher;
	import org.mixingloom.preloader.watcher.IPatcherApplier;
	import org.mixingloom.preloader.watcher.PatcherApplierImpl;
	
	public class PatchManager implements IPatchManager {
		private var patchers:Vector.<IPatcher>;
		private var _preloader:Preloader;
		private var _rslItemList:Array;
		private var _kickedOffInit:Boolean = false;
		private var _initReady:Boolean = false;
		private var _frame2Ready:Boolean = false;

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
		
		public function get preloader():Preloader
		{
			return _preloader;
		}
		
		public function cleanUpManager():void {
			if ( _preloader ) {
				_preloader.removeEventListener( FlexEvent.PRELOADER_DOC_FRAME_READY,
					handleFrame2Ready,
					false );
				_preloader.removeEventListener( RSLEvent.RSL_COMPLETE,
					handleRSLComplete,
					false );
				
			}
		}
		
		private function handleInitReady( event:Event=null ):void {
			_initReady = true;
			
			checkFrame2Apply();
		}
		
		private function handleFrame2Ready( event:FlexEvent ):void {
			_frame2Ready = true;
			
			//We stop the systemManager from moving forward into frame 2
			event.stopImmediatePropagation();
			
			_preloader.removeEventListener( FlexEvent.PRELOADER_DOC_FRAME_READY, 
				handleFrame2Ready, 
				false );
			
			checkFrame2Apply();
		}
		
		private function checkFrame2Apply():void
		{
			if ((rslsComplete) && (_initReady) && (_frame2Ready)) 
			{
				var parser:ByteParser = new ByteParser();
				var frame2SwfContext:SwfContext = new SwfContext();
				frame2SwfContext.originalUncompressedSwfBytes = parser.uncompressSwf( _preloader.loaderInfo.bytes );
				frame2SwfContext.swfTags = parser.getFrameTwoTags(frame2SwfContext.originalUncompressedSwfBytes);
				
				var applier:IPatcherApplier = createApplier( new InvocationType( InvocationType.FRAME2, _preloader.loaderInfo.url ), frame2SwfContext );
				applier.setCallBack( moveToFrame2 );
				applier.apply();
			}
		}
		
		private function removeRSLFromList( url:String ):void {
			var rsl:LoomCrossDomainRSLItem;
			if (_rslItemList != null)
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
			
			checkFrame2Apply();
		}
		
		private function moveToFrame2(event:Event=null):void {
			//we allow the system manager to move to frame 2
			_preloader.dispatchEvent( new FlexEvent( FlexEvent.PRELOADER_DOC_FRAME_READY ) );
		}

        public function patchersReady():void {
			// provide a way to load bytes unrelated to a frame
			var swfContext:SwfContext = new SwfContext();
			swfContext.originalUncompressedSwfBytes = new ByteArray();
			swfContext.swfTags = new Vector.<SwfTag>();
			var applier:IPatcherApplier = createApplier( new InvocationType( InvocationType.INIT, _preloader.loaderInfo.url ), swfContext );
			applier.setCallBack(handleInitReady);
			applier.apply();
        }
		
		public function PatchManager() {
			patchers = new Vector.<IPatcher>();
		}
	}
}
