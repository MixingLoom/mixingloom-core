/**
 * Created by IntelliJ IDEA.
 * User: James Ward <james@jamesward.org>
 * Date: 4/4/11
 * Time: 12:52 PM
 */
package org.mixingloom.utils {
import flash.utils.ByteArray;

public class ByteArrayUtils {
    public static function indexOf(haystack:ByteArray, needle:ByteArray):uint {

        if (haystack.length < needle.length) {
            throw new Error("the needle length must be less than or equal to the haystack length");
        }


        for (var i:uint = 0; i < (haystack.length - needle.length - 1); i++)
        {
          haystack.position = i;

          var testByteArray:ByteArray = new ByteArray();
          haystack.readBytes(testByteArray, 0, needle.length);

          var notInThere:Boolean = false;

          needle.position = 0;
          testByteArray.position = 0;
          for (var j:uint = 0; j < needle.length; j++) {
            if (needle.readByte() != testByteArray.readByte()) {
              notInThere = true;
              break;
            }
          }

          if (!notInThere)
          {
            return i;
          }

        }

        return -1;
    }

}
}
