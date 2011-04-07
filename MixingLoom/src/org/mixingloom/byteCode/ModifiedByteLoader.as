package org.mixingloom.byteCode {
import flash.display.Loader;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.net.FileReference;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.utils.ByteArray;
import flash.utils.Endian;

import mx.managers.SystemManagerGlobals;

import org.mixingloom.SwfContext;
import org.mixingloom.SwfTag;


public class ModifiedByteLoader {
    private var callBack:Function;
    public var loaderContext:LoaderContext;
    public var forceLoad:Boolean = true;

    protected function invokeCallBack(args:Array=null):void {
        if ( callBack != null ) {
            callBack.apply(null, args);
        }
    }

    public function setCallBack(value:Function):void {
        this.callBack = value;
    }

    public function applyModificiations( swfContext:SwfContext ):void {
        var swfTags:Vector.<SwfTag> = swfContext.swfTags;
        var numTagsModified:uint = 0;

        var modifiedBytes:ByteArray = new ByteArray();
        modifiedBytes.endian = Endian.LITTLE_ENDIAN;

        for each (var swfHeaderByte:int in [0x46, 0x57, 0x53, 0x0a, 0xff, 0xff, 0xff, 0xff, 0x70, 0x00, 0x0b, 0xb8, 0x00, 0x00, 0xbb, 0x80, 0x00, 0x18, 0x01, 0x00])
        {
            modifiedBytes.writeByte(swfHeaderByte);
        }

        // write the file attributes
        for each (var fileAttrByte:int in [0x44, 0x11, 0x08, 0x00, 0x00, 0x00])
        {
            modifiedBytes.writeByte(fileAttrByte);
        }

        for each (var swfTag:SwfTag in swfTags)
        {
            //trace('writing tag ' + swfTag.name + " " + swfTag.type);
            //if (swfTag.modified)
            //{
            numTagsModified++;
            modifiedBytes.writeBytes(swfTag.recordHeader);
            modifiedBytes.writeBytes(swfTag.tagBody);
            //}
        }

        if ((numTagsModified < 1) && (!forceLoad))
        {
            // just finish
            invokeCallBack();
            return;
        }

        // show frame tag
        modifiedBytes.writeByte(0x40);
        modifiedBytes.writeByte(0);

        // write the swf footer
        modifiedBytes.writeByte(0);
        modifiedBytes.writeByte(0);

        // set the length of the total SWF
        modifiedBytes.position = 4;
        modifiedBytes.writeUnsignedInt(modifiedBytes.length);

        modifiedBytes.position = 0;

        trace('modifiedBytes.length = ' + modifiedBytes.length);

        // todo: would be nice to have a way when debugging to save the modified bytes for later download
        /*
        trace('modifiedBytes_'+modifiedBytes.length);
        SystemManagerGlobals.topLevelSystemManagers[0].info()['modifiedBytes_'+modifiedBytes.length] = modifiedBytes;
        SystemManagerGlobals.topLevelSystemManagers[0].stage.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
            var f:FileReference = new FileReference();
            f.save(SystemManagerGlobals.topLevelSystemManagers[0].info()['modifiedBytes_1998359'], "modified.swf");
        });
        */

        if (loaderContext == null)
        {
            loaderContext = new LoaderContext();
            loaderContext.applicationDomain = ApplicationDomain.currentDomain;
        }

        var loader:Loader = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleLoaderComplete);
        loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleLoaderError);
        loader.loadBytes(modifiedBytes, loaderContext);
    }

    private function handleLoaderComplete(event:Event):void
    {
        invokeCallBack([event]);
    }

    private function handleLoaderError(event:IOErrorEvent):void
    {
        invokeCallBack([event]);
    }

    public function ModifiedByteLoader() {
        super();
    }
}
}