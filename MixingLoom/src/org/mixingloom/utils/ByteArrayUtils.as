/**
 * Created by IntelliJ IDEA.
 * User: James Ward <james@jamesward.org>
 * Date: 4/4/11
 * Time: 12:52 PM
 */
package org.mixingloom.utils {
import flash.utils.ByteArray;

public class ByteArrayUtils {
    
    public static function indexOf(haystack:ByteArray, needle:ByteArray):int {

        if (haystack.length < needle.length) {
            throw new Error("the needle length must be less than or equal to the haystack length");
        }

        for (var i:uint = 0; i < (haystack.length - needle.length - 1); i++) {
            haystack.position = i;

            var testByteArray:ByteArray = new ByteArray();
            haystack.readBytes(testByteArray, 0, needle.length);

            needle.position = 0;
            if (equals(testByteArray, needle)) {
                return i;
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