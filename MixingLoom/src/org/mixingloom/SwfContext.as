/**
 * Created by IntelliJ IDEA.
 * User: James Ward <james@jamesward.org>
 * Date: 3/23/11
 * Time: 1:24 PM
 */
package org.mixingloom
{
import flash.utils.ByteArray;

public class SwfContext
{
  public var originalUncompressedSwfBytes:ByteArray;
  public var swfTags:Vector.<SwfTag>;
  public var swfInfos:*;

  public function toString():String
  {
    return "originalUncompressedSwfBytes.length = " + originalUncompressedSwfBytes.length + " swfTags.length = " + swfTags.length;
  }
}
}