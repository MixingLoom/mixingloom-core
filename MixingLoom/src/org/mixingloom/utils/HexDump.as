/**
 * Created by IntelliJ IDEA.
 * User: James Ward <james@jamesward.org>
 * Date: 3/14/11
 * Time: 4:39 PM
 */
package org.mixingloom.utils
{
import flash.utils.ByteArray;

public class HexDump
{
  public static function dumpHex(bytes:ByteArray):String
  {
    var originalPos:uint = bytes.position;

    var s:String = "";
    var i:uint = 0;
    var chunk:Array = new Array();

    while (i < bytes.length)
    {

      if (((i % 16) == 0) && (i != 0))
      {
        s += writeChunk(chunk, 16) + "\n";
        chunk = [];
      }

      chunk.push(bytes.readUnsignedByte());

      i++;
    }
    s += writeChunk(chunk, 16);

    bytes.position = originalPos;

    return s;
  }

  public static function writeChunk(chunk:Array, width:uint):String
  {
    var s:String = "";

    for (var i:uint = 0; i < chunk.length; i++)
    {
      if (((i % 4) == 0) && (i != 0))
      {
        s += " ";
      }

      var b:uint = chunk[i];

      var ss:String = b.toString(16) + " ";
      if (ss.length == 2)
      {
        ss = "0" + ss;
      }

      s += ss;
    }

    for (var j:uint = 0; j < (width - chunk.length); j++)
    {
      s += "   ";
    }

    var k:uint = Math.floor((width - chunk.length) / 4);
    for (var l:uint = 0; l < k; l++)
    {
      s += " ";
    }

    s += "   ";

    for (var m:uint = 0; m < chunk.length; m++)
    {
      var c:uint = chunk[m];

      if ((c <= 126) && (c > 32))
      {
        var sss:String = String.fromCharCode(c);
        s += sss;
      }
      else
      {
        s += ".";
      }
    }

    return s;
  }
}
}
