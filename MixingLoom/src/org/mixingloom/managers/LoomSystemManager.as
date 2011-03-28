package org.mixingloom.managers {
	import flash.display.Loader;
import flash.events.MouseEvent;
import flash.system.ApplicationDomain;
	
	import mx.core.IFlexModuleFactory;
	import mx.core.RSLData;
	import mx.core.RSLItem;
	import mx.core.mx_internal;
	import mx.events.RSLEvent;
	import mx.managers.SystemManager;
	import mx.utils.LoaderUtil;
	
	import org.mixingloom.core.LoomCrossDomainRSLItem;
import org.mixingloom.patcher.IPatcher;

use namespace mx_internal;

	public class LoomSystemManager extends SystemManager {

		private var rslDataList:Array;
		private var patchManager:IPatchManager;

		override mx_internal function initialize():void {
			var info:Object = info();

      patchManager = createPatchManager();

			//Store the rsls
			var rsls:Array = info["rsls"];
			var cdRsls:Array = info["cdRsls"];

			//Rsls, what rsls?
			info[ "cdRsls" ] = [];
			info[ "rsls" ] = [];

			//Store the module url list
			var resourceModuleURLList:String =
				loaderInfo.parameters["resourceModuleURLs"];
			var resourceModuleURLs:Array =
				resourceModuleURLList ? resourceModuleURLList.split(",") : null;

			//url list? what url list
			loaderInfo.parameters["resourceModuleURLs"] = "";
			
			var usePreloaderDisplay:Boolean = true;
			if (info["usePreloader"] != undefined)
				usePreloaderDisplay = info["usePreloader"];
			
			var preloaderDisplayClass:Class = info["preloader"] as Class;

			//turns out we don't want your preloader display
			delete info[ "usePreloader" ];

			var domain:ApplicationDomain =
				!topLevel && parent is Loader ?
				Loader(parent).contentLoaderInfo.applicationDomain :
				info["currentDomain"] as ApplicationDomain;

			super.initialize();
			
			//Okay, now, how you might actually write code
			var rslItemList:Array = createRSLItemList( patchManager, rsls, cdRsls );

			patchManager.preloader = preloader;
			patchManager.rslItemList = rslItemList; 

			reInitPreloader( patchManager, usePreloaderDisplay, preloaderDisplayClass, rslItemList, resourceModuleURLs, domain );
		}
		
		protected function reInitPreloader( patchManager:IPatchManager, usePreloaderDisplay:Boolean, preloaderDisplayClass:Class, rslItemList:Array, resourceModuleURLs:Array, domain:ApplicationDomain = null  ):void {
			preloader.addEventListener(RSLEvent.RSL_COMPLETE, 
				preloader_rslCompleteHandler, false, 1000 );

			// Initialize the preloader.
			preloader.initialize(
				usePreloaderDisplay,
				preloaderDisplayClass,
				preloaderBackgroundColor,
				preloaderBackgroundAlpha,
				preloaderBackgroundImage,
				preloaderBackgroundSize,
				isStageRoot ? stage.stageWidth : loaderInfo.width,
				isStageRoot ? stage.stageHeight : loaderInfo.height,
				null,
				null,
				rslItemList,
				resourceModuleURLs,
				domain);
			
			if ( preloader.numChildren > 0 ) {
				var visualPreloader:* = preloader.getChildAt( 0 );
				if ( visualPreloader is IPatchManagerClient ) {
					( visualPreloader as IPatchManagerClient ).patchManager = patchManager;
				}
			}
		}

		protected function createRSLItemList( patchManager:IPatchManager, rsls:Array, cdRsls:Array ):Array {
			// Put cross-domain RSL information in the RSL list.
			var rslItemList:Array = [];
			var n:int;
			var i:int;
			if (cdRsls && cdRsls.length > 0) {
				if (isTopLevel())
					rslDataList = cdRsls;
				else
					rslDataList = LoaderUtil.processRequiredRSLs(this, cdRsls);
				
				var normalizedURL:String = LoaderUtil.normalizeURL(this.loaderInfo);
				n = rslDataList.length;
				for (i = 0; i < n; i++) {
					var rslWithFailovers:Array = rslDataList[i];
					
					// If crossDomainRSLItem is null, then this is a compiler error. It should not be null.
					var cdNode:Object = createCrossDomainRSLItem( patchManager, rslWithFailovers, normalizedURL, this );   
					rslItemList.push(cdNode);               
				}
			}
			
			// Append RSL information in the RSL list.
			if (rsls != null && rsls.length > 0) {
				if (rslDataList == null)
					rslDataList = [];
				
				if (normalizedURL == null)
					normalizedURL = LoaderUtil.normalizeURL(this.loaderInfo);
				
				n = rsls.length;
				for (i = 0; i < n; i++) {
					var node:RSLItem = new RSLItem(rsls[i].url, 
						normalizedURL,
						this);
					rslItemList.push(node);
					rslDataList.push([new RSLData(rsls[i].url, null, null, null, 
						false, false, "current")]);
				}
			}
			
			return rslItemList;
		}

		protected function createCrossDomainRSLItem( patchManager:IPatchManager,
													 rsls:Array,
													 rootURL:String = null,
													 moduleFactory:IFlexModuleFactory = null ):RSLItem {
			return new LoomCrossDomainRSLItem( patchManager, rsls, rootURL, moduleFactory);
		}

		
		protected function createPatchManager():IPatchManager {
			return new PatchManager();
		}

		/**
		 *  @private
		 *  The preloader has completed loading an RSL.
		 */
		private function preloader_rslCompleteHandler(event:RSLEvent):void {
			//We need to prevent the copy in the original system manager from getting
			//this event
			event.stopImmediatePropagation();

			if (!event.isResourceModule && event.loaderInfo) {
				var rsl:Vector.<RSLData> = Vector.<RSLData>(rslDataList[event.rslIndex]);
				var moduleFactory:IFlexModuleFactory = this;
				if (rsl && rsl[0].moduleFactory)
					moduleFactory = rsl[0].moduleFactory; 
				
				if (moduleFactory == this)
					preloadedRSLs[event.loaderInfo] =  rsl;
				else
					moduleFactory.addPreloadedRSL(event.loaderInfo, rsl);
			}
		}

		public function LoomSystemManager() {
			super();
		}
	}
}