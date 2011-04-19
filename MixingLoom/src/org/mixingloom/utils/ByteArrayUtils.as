/**
 * Created by IntelliJ IDEA.
 * User: James Ward <james@jamesward.org>
 * Date: 4/4/11
 * Time: 12:52 PM
 */
package org.mixingloom.utils {
import flash.utils.ByteArray;

// todo: unit test this bitch
public class ByteArrayUtils {

    public static function findAndReplaceFirstOccurrence(haystack:ByteArray, needle:ByteArray, replacement:ByteArray):ByteArray
    {
        var indexOfNeedle:int = indexOf(haystack, needle);

        if (indexOfNeedle == -1)
        {
            return haystack;
        }

        var newByteArray:ByteArray = new ByteArray();
        if (indexOfNeedle > 0)
        {
            newByteArray.writeBytes(haystack, 0, indexOfNeedle);
        }

        newByteArray.writeBytes(replacement);

        newByteArray.writeBytes(haystack, indexOfNeedle + needle.length);

        newByteArray.position = 0;

        return newByteArray;
    }

    public static function subByteArray(byteArray:ByteArray, start:uint, length:uint):ByteArray
    {
        var sub:ByteArray = new ByteArray();
        sub.writeBytes(byteArray, start,  length);
        return sub;
    }


    public static function indexOf(haystack:ByteArray, needle:ByteArray):int {

        if (haystack.length < needle.length) {
            throw new Error("the needle length must be less than or equal to the haystack length");
        }

        var haystackPos:uint = haystack.position;
        var needlePos:uint = needle.position;

        haystack.position = 0;
        needle.position = 0;

        var count:uint = 0;
        for (var i:uint = 0; i < haystack.length; i++)
        {
            if (haystack[i] == needle[count])
            {
                count++;
            }
            else
            {
                count = 0;
            }

            if (count == needle.length)
            {
                return (i - count + 1);
            }
        }

        return -1;
    }

    public static function equals(a:ByteArray, b:ByteArray):Boolean {

        if (a.length != b.length) {
            throw new Error("lengths are not equal!");
        }

        var isEqual:Boolean = true;

        var aPos:uint = a.position;
        var bPos:uint = b.position;

        a.position = 0;
        b.position = 0;

        for (var i:uint = 0; i < a.length; i++) {

            if (a.readByte() != b.readByte()) {
                isEqual = false;
                break;
            }
        }

        a.position = aPos;
        b.position = bPos;

        return isEqual;
    }

}
}