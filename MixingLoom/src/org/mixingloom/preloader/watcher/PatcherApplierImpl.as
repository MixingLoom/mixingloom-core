package org.mixingloom.preloader.watcher {
import avmplus.accessorXml;

import flash.system.LoaderContext;

import org.mixingloom.SwfContext;
import org.mixingloom.byteCode.ModifiedByteLoader;
import org.mixingloom.invocation.InvocationType;
import org.mixingloom.patcher.IPatcher;

public class PatcherApplierImpl implements IPatcherApplier {

    private var callBack:Function;

    private var _patchers:Vector.<IPatcher>;
    private var _swfContext:SwfContext;
    private var _invocationType:InvocationType;
    private var _loaderContext:LoaderContext;

    public function get allPatchesComplete():Boolean {
        return ( _patchers.length == 0 );
    }

    public function get invocationType():InvocationType
    {
        return _invocationType;
    }

    public function set invocationType(value:InvocationType):void
    {
        _invocationType = value;
    }

    public function get swfContext():SwfContext
    {
        return _swfContext;
    }

    public function set swfContext(value:SwfContext):void
    {
        _swfContext = value;
    }

    public function set patchers( value:Vector.<IPatcher> ):void {
        _patchers = value.slice();
    }

    public function get loaderContext():LoaderContext
    {
        return _loaderContext;
    }

    public function set loaderContext(_loaderContext:LoaderContext):void {
        this._loaderContext = _loaderContext;
    }


    public function apply():void {
        startNextPatch();
    }

    public function setCallBack(value:Function):void {
        this.callBack = value;
    }

    protected function invokeCallBack(... args:Array):void {
        if ( callBack != null ) {
            callBack.apply(null, args);
        }
    }

    private function startNextPatch():void {
        if ( !allPatchesComplete ) {
            var patcher:IPatcher = _patchers.shift();
            patcher.setCallBack( handleComplete, [patcher] );
            patcher.apply( invocationType, swfContext );
        } else {
            var modifier:ModifiedByteLoader = new ModifiedByteLoader();
            modifier.loaderContext = loaderContext;
            modifier.setCallBack( invokeCallBack );
            modifier.applyModificiations( swfContext );
        }
    }

    private function handleComplete( patcher:IPatcher ):void {
        //clean up
        patcher.setCallBack( null );

        startNextPatch();
    }

    public function PatcherApplierImpl() {
        patchers = new Vector.<IPatcher>();
    }

}
}