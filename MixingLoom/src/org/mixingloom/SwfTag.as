/**
 * Created by IntelliJ IDEA.
 * User: James Ward <james@jamesward.org>
 * Date: 3/14/11
 * Time: 5:00 PM
 */
package org.mixingloom
{
import flash.utils.ByteArray;
import flash.utils.Endian;

import org.mixingloom.utils.HexDump;

public class SwfTag
{

    public var name:String;

    public var type:uint;

    public var tagBody:ByteArray;

    
    public function get fullTag():ByteArray
    {
        var fullTag:ByteArray = new ByteArray();
        fullTag.endian = Endian.LITTLE_ENDIAN;

        var tagCodeAndLength:uint = 0;
        tagCodeAndLength = type << 6;

        if (tagBody.length <= 62)
        {
            tagCodeAndLength |= tagBody.length;
            fullTag.writeShort(tagCodeAndLength);
        }
        else
        {
            tagCodeAndLength |= 0x3f;
            fullTag.writeShort(tagCodeAndLength);
            fullTag.writeInt(tagBody.length);
        }

        fullTag.writeBytes(tagBody);

        return fullTag;
    }

}
}