package org.mixingloom.preloader {
	public interface IPatchNotifier {
		function allPatchesComplete():void;
		function byteModificationComplete():void;
	}
}