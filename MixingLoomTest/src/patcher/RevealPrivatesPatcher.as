/**
 * Created by IntelliJ IDEA.
 * User: James Ward <james@jamesward.org>
 * Date: 3/23/11
 * Time: 1:34 PM
 */
package patcher
{
import flash.display.Loader;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.utils.ByteArray;
import flash.utils.Endian;

import org.as3commons.bytecode.abc.AbcFile;
import org.as3commons.bytecode.abc.InstanceInfo;
import org.as3commons.bytecode.abc.LNamespace;
import org.as3commons.bytecode.abc.MethodBody;
import org.as3commons.bytecode.abc.TraitInfo;
import org.as3commons.bytecode.io.AbcDeserializer;
import org.as3commons.bytecode.io.AbcSerializer;
import org.as3commons.bytecode.util.SWFSpec;
import org.mixingloom.SwfContext;
import org.mixingloom.SwfTag;
import org.mixingloom.invocation.InvocationType;
import org.mixingloom.patcher.AbstractPatcher;
import org.mixingloom.patcher.IPatcher;
import org.mixingloom.preloader.watcher.IPatcherApplier;

public class RevealPrivatesPatcher extends AbstractPatcher {

  public var classTagName:String;

  public var propertyOrMethodName:String;

  public function RevealPrivatesPatcher(classTagName:String, propertyOrMethodName:String)
  {
    this.classTagName = classTagName;
    this.propertyOrMethodName = propertyOrMethodName;
  }

  override public function apply( invocationType:InvocationType, swfContext:SwfContext ):void {
    applier.startPatching( this );

    var uncompressedSwf:ByteArray = uncompressSwf(swfContext.swfBytes);

    // we can only modify frame 2 tags
    var swfTags:Array = getFrameTwoTags(uncompressedSwf);

    run(swfTags);

    loadModifiedTags(swfTags);
    //applier.completePatching( this );
  }

  public function run(swfTags:Array):void
  {
    trace('RevealPrivatesPatcher run()');

    for each (var swfTag:SwfTag in swfTags)
    {
      //trace(swfTag.name, classTagName);
      if (swfTag.name == classTagName)
      {
        trace('found ' + classTagName);

        // skip the flags
        swfTag.tagBody.position = 4;

        var abcStartLocation:uint = 4;
        while (swfTag.tagBody.readByte() != 0)
        {
          abcStartLocation++;
        }
        abcStartLocation++; // skip the string byte terminator

        swfTag.tagBody.position = 0;

        var abcDeserializer:AbcDeserializer = new AbcDeserializer(swfTag.tagBody);

        var origAbcFile:AbcFile = abcDeserializer.deserialize(abcStartLocation);

        // check the methods
        for each (var mb:MethodBody in origAbcFile.methodBodies)
        {
          if (!(mb.methodSignature.as3commonsBytecodeName is String))
          {
            if (mb.methodSignature.as3commonsBytecodeName.name == propertyOrMethodName)
            {
              mb.methodSignature.as3commonsBytecodeName.nameSpace = LNamespace.PUBLIC;
              mb.methodSignature.scopeName = mb.methodSignature.as3commonsBytecodeName.nameSpace.kind.description;
              trace('method updated');
            }
          }
        }

        // check the properties
        //trace(origAbcFile.instanceInfo);

        for each (var ci:InstanceInfo in origAbcFile.instanceInfo)
        {
          for each (var t:TraitInfo in ci.traits)
          {
            if (t.traitMultiname.name == propertyOrMethodName)
            {
              t.traitMultiname.nameSpace = LNamespace.PUBLIC;
              trace('trait update');
            }
          }
        }

        var abcSerializer:AbcSerializer = new AbcSerializer();
        var abcByteArray:ByteArray = abcSerializer.serializeAbcFile(origAbcFile);

        swfTag.tagBody = new ByteArray();
        swfTag.tagBody.endian = Endian.LITTLE_ENDIAN;

        // 4 byte flags
        swfTag.tagBody.writeByte(0x01);
        swfTag.tagBody.writeByte(0);
        swfTag.tagBody.writeByte(0);
        swfTag.tagBody.writeByte(0);

        // tag name
        swfTag.tagBody.writeUTFBytes(classTagName);
        swfTag.tagBody.writeByte(0);

        // method body
        swfTag.tagBody.writeBytes(abcByteArray);

        trace('tag length = ' + swfTag.tagBody.length);

        swfTag.recordHeader = new ByteArray();
        swfTag.recordHeader.endian = Endian.LITTLE_ENDIAN;
        swfTag.recordHeader.writeByte(0xbf);
        swfTag.recordHeader.writeByte(0x14);
        swfTag.recordHeader.writeInt(swfTag.tagBody.length);

        swfTag.modified = true;
      }
    }
  }

  public function uncompressSwf(input:ByteArray):ByteArray
  {
    var output:ByteArray;

    if (input.readByte() == 0x43)
    {
      var swfGuts:ByteArray = new ByteArray();
      input.position = 0;
      swfGuts.writeBytes(input, 8);
      swfGuts.position = 0;
      swfGuts.uncompress();

      output = new ByteArray();
      output.endian = Endian.LITTLE_ENDIAN;
      output.writeByte(0x46);
      output.writeByte(0x57);
      output.writeByte(0x53);
      output.writeByte(0x0a);
      output.writeUnsignedInt(swfGuts.length + 8);
      output.writeBytes(swfGuts);
    }
    else
    {
      output = input;
      output.endian = Endian.LITTLE_ENDIAN;
    }
    output.position = 0;

    return output;
  }

  public function getFrameTwoTags(byteArray:ByteArray):Array
  {
    var allSwfTags:Object = new Object();
    var currentFrame:uint = 0;

    for each (var swfTag:SwfTag in getAllSwfTags(byteArray))
    {
      if (swfTag.type == 43)
      {
        currentFrame++;
      }

      if (allSwfTags[currentFrame] == undefined)
      {
        allSwfTags[currentFrame] = new Array();
      }

      (allSwfTags[currentFrame] as Array).push(swfTag);
    }

    return allSwfTags[2];
  }

  public function loadModifiedTags(swfTags:Array):void
  {
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
      //trace('writing tag ' + swfTag.name);
      //if (swfTag.modified)
      //{
      numTagsModified++;
      modifiedBytes.writeBytes(swfTag.recordHeader);
      modifiedBytes.writeBytes(swfTag.tagBody);
      //}
    }

    if (numTagsModified < 1)
    {
      // just finish
      applier.completePatching( this );
      return;
    }

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

    var loaderContext:LoaderContext = new LoaderContext();
    loaderContext.applicationDomain = ApplicationDomain.currentDomain;

    var loader:Loader = new Loader();
    loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleLoaderComplete);
    loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleLoaderError);
    loader.loadBytes(modifiedBytes, loaderContext);
  }

  private function handleLoaderComplete(event:Event):void
  {
    applier.completePatching( this );
  }

  private function handleLoaderError(event:IOErrorEvent):void
  {
    applier.completePatching( this );
  }

  public function getAllSwfTags(originalBytes:ByteArray):Array
  {
    var swfTags:Array = new Array();

    // skip the header
    originalBytes.position = 8;

    // read framesize
    var fsByte:uint = originalBytes.readUnsignedByte();
    // it's really only 5 bits
    fsByte >>>= 3;

    // there are 4 of them
    var fsBits:uint = fsByte * 4;

    // we already read 3 extra bits
    fsBits -= 3;

    // number of additional bytes to move to get past the framesize
    var fsBytes:uint = Math.ceil(fsBits / 8);

    originalBytes.position += fsBytes;

    // move another 4 bytes past the frame rate and frame count
    originalBytes.position += 4;

    // read the tags
    while (originalBytes.position < (originalBytes.length - 2))
    {
      swfTags.push(readTag(originalBytes))
    }

    originalBytes.position = 0;

    return swfTags;
  }

  public function readTag(originalBytes:ByteArray):SwfTag
  {
    var swfTag:SwfTag = new SwfTag();

    // read the record header
    var tagCodeAndLength:uint = originalBytes.readUnsignedShort();
    swfTag.recordHeader.writeShort(tagCodeAndLength);
    swfTag.type = tagCodeAndLength >> 6;
    swfTag.tagLengthExcludingRecordHeader = tagCodeAndLength & 0x3f;
    if (swfTag.tagLengthExcludingRecordHeader == 0x3f)
    {
      swfTag.tagLengthExcludingRecordHeader = originalBytes.readUnsignedInt();
      swfTag.recordHeader.writeUnsignedInt(swfTag.tagLengthExcludingRecordHeader);
    }
    swfTag.tagBody = new ByteArray();
    if (swfTag.tagLengthExcludingRecordHeader > 0)
    {
      originalBytes.readBytes(swfTag.tagBody, 0, swfTag.tagLengthExcludingRecordHeader);
    }

    //trace('type = ' + swfTag.type);
    //trace('tagLengthExcludingRecordHeader = ' + swfTag.tagLengthExcludingRecordHeader);
    //trace(HexDump.dumpHex(swfTag.tagBody));

    if (swfTag.type == 82)
    {
      // skip the flags
      swfTag.tagBody.position += 4;

      swfTag.name = SWFSpec.readString(swfTag.tagBody);

      swfTag.tagBody.position = 0;
    }

    return swfTag;
  }

}
}
