/**
 * Created by IntelliJ IDEA.
 * User: James Ward <james@jamesward.org>
 * Date: 3/24/11
 * Time: 2:03 PM
 */
package org.mixingloom.tests
{
import flash.utils.ByteArray;

import org.flexunit.asserts.assertEquals;

import org.mixingloom.utils.ByteArrayUtils;

public class ByteArrayUtilsTest
{

  [Test]
  public function indexOfOneByteInOneByte():void
  {
      var needleByte:int = 0x1;

      var haystack:ByteArray = new ByteArray();
      haystack.writeByte(needleByte);

      var needle:ByteArray = new ByteArray();
      needle.writeByte(needleByte);

      var pos:int = ByteArrayUtils.indexOf(haystack, needle);
      assertEquals(pos, 0);
  }

  [Test]
  public function indexOfOneByteInOneByteNotThere():void
  {
      var needleByte:int = 0x1;

      var haystack:ByteArray = new ByteArray();
      haystack.writeByte(needleByte);

      var needle:ByteArray = new ByteArray();
      needle.writeByte(0x2);

      var pos:int = ByteArrayUtils.indexOf(haystack, needle);
      assertEquals(pos, -1);
  }

  [Test]
  public function indexOfOneByteInTwoBytesAtFirstByte():void
  {
      var needleByte:int = 0x1;

      var haystack:ByteArray = new ByteArray();
      haystack.writeByte(needleByte);
      haystack.writeByte(needleByte);

      var needle:ByteArray = new ByteArray();
      needle.writeByte(needleByte);

      var pos:int = ByteArrayUtils.indexOf(haystack, needle);
      assertEquals(pos, 0);
  }

  [Test]
  public function indexOfOneByteInTwoBytesAtSecondByte():void
  {
      var needleByte:int = 0x1;

      var haystack:ByteArray = new ByteArray();
      haystack.writeByte(0x2);
      haystack.writeByte(needleByte);

      var needle:ByteArray = new ByteArray();
      needle.writeByte(needleByte);

      var pos:int = ByteArrayUtils.indexOf(haystack, needle);
      assertEquals(pos, 1);
  }

  [Test]
  public function findAndReplaceOneByteWholeThing():void
  {
      var replacementByte:int = 0x2;
      var haystack:ByteArray = new ByteArray();
      haystack.writeByte(0x1);

      var needle:ByteArray = new ByteArray();
      needle.writeByte(0x1);

      var replacement:ByteArray = new ByteArray();
      replacement.writeByte(replacementByte);

      var result:ByteArray = ByteArrayUtils.findAndReplaceFirstOccurrence(haystack, needle, replacement);
      assertEquals(result.length, (haystack.length - needle.length + replacement.length));
      assertEquals(result.readByte(), replacementByte);
  }

  [Test]
  public function findAndReplaceFirstByteInTwo():void
  {
      var searchByte:int = 0x1;
      var replacementByte:int = 0x2;
      var haystack:ByteArray = new ByteArray();
      haystack.writeByte(searchByte);
      haystack.writeByte(replacementByte);

      var needle:ByteArray = new ByteArray();
      needle.writeByte(searchByte);

      var replacement:ByteArray = new ByteArray();
      replacement.writeByte(replacementByte);

      var result:ByteArray = ByteArrayUtils.findAndReplaceFirstOccurrence(haystack, needle, replacement);
      assertEquals(result.length, (haystack.length - needle.length + replacement.length));
      assertEquals(result.readByte(), replacementByte);
      assertEquals(result.readByte(), replacementByte);
  }

  [Test]
  public function findAndReplaceOneMiddleByteInThree():void
  {
      var searchByte:int = 0x2;
      var replacementByte:int = 0x4;
      var haystack:ByteArray = new ByteArray();
      haystack.writeByte(0x1);
      haystack.writeByte(searchByte);
      haystack.writeByte(0x3);

      var needle:ByteArray = new ByteArray();
      needle.writeByte(searchByte);

      var replacement:ByteArray = new ByteArray();
      replacement.writeByte(replacementByte);

      var result:ByteArray = ByteArrayUtils.findAndReplaceFirstOccurrence(haystack, needle, replacement);
      assertEquals(result.length, (haystack.length - needle.length + replacement.length));
      assertEquals(result.readByte(), 0x1);
      assertEquals(result.readByte(), replacementByte);
      assertEquals(result.readByte(), 0x3);
  }

  [Test]
  public function findAndReplaceFirstTwoBytesInThree():void
  {
      var searchByte1:int = 0x1;
      var searchByte2:int = 0x2;
      var replacementByte1:int = 0x4;
      var replacementByte2:int = 0x5;

      var haystack:ByteArray = new ByteArray();
      haystack.writeByte(searchByte1);
      haystack.writeByte(searchByte2);
      haystack.writeByte(0x3);

      var needle:ByteArray = new ByteArray();
      needle.writeByte(searchByte1);
      needle.writeByte(searchByte2);

      var replacement:ByteArray = new ByteArray();
      replacement.writeByte(replacementByte1);
      replacement.writeByte(replacementByte2);

      var result:ByteArray = ByteArrayUtils.findAndReplaceFirstOccurrence(haystack, needle, replacement);
      assertEquals(result.length, (haystack.length - needle.length + replacement.length));
      assertEquals(result.readByte(), replacementByte1);
      assertEquals(result.readByte(), replacementByte2);
      assertEquals(result.readByte(), 0x3);
  }

  [Test]
  public function findAndReplaceLastTwoBytesInThree():void
  {
      var searchByte1:int = 0x2;
      var searchByte2:int = 0x3;
      var replacementByte1:int = 0x4;
      var replacementByte2:int = 0x5;

      var haystack:ByteArray = new ByteArray();
      haystack.writeByte(0x1);
      haystack.writeByte(searchByte1);
      haystack.writeByte(searchByte2);

      var needle:ByteArray = new ByteArray();
      needle.writeByte(searchByte1);
      needle.writeByte(searchByte2);

      var replacement:ByteArray = new ByteArray();
      replacement.writeByte(replacementByte1);
      replacement.writeByte(replacementByte2);

      var result:ByteArray = ByteArrayUtils.findAndReplaceFirstOccurrence(haystack, needle, replacement);
      assertEquals(result.length, (haystack.length - needle.length + replacement.length));
      assertEquals(result.readByte(), 0x1);
      assertEquals(result.readByte(), replacementByte1);
      assertEquals(result.readByte(), replacementByte2);
  }

  [Test]
  public function findAndReplaceOneByteWithTwoBytes():void
  {
      var searchByte:int = 0x1;
      var replacementByte1:int = 0x2;
      var replacementByte2:int = 0x3;

      var haystack:ByteArray = new ByteArray();
      haystack.writeByte(searchByte);

      var needle:ByteArray = new ByteArray();
      needle.writeByte(searchByte);

      var replacement:ByteArray = new ByteArray();
      replacement.writeByte(replacementByte1);
      replacement.writeByte(replacementByte2);

      var result:ByteArray = ByteArrayUtils.findAndReplaceFirstOccurrence(haystack, needle, replacement);
      assertEquals(result.length, (haystack.length - needle.length + replacement.length));
      assertEquals(result.readByte(), replacementByte1);
      assertEquals(result.readByte(), replacementByte2);
  }

  [Test]
  public function findAndReplaceFirstByteInTwoBytesWithTwoBytes():void
  {
      var searchByte:int = 0x1;
      var replacementByte1:int = 0x3;
      var replacementByte2:int = 0x4;

      var haystack:ByteArray = new ByteArray();
      haystack.writeByte(searchByte);
      haystack.writeByte(0x2);

      var needle:ByteArray = new ByteArray();
      needle.writeByte(searchByte);

      var replacement:ByteArray = new ByteArray();
      replacement.writeByte(replacementByte1);
      replacement.writeByte(replacementByte2);

      var result:ByteArray = ByteArrayUtils.findAndReplaceFirstOccurrence(haystack, needle, replacement);
      assertEquals(result.length, (haystack.length - needle.length + replacement.length));
      assertEquals(result.readByte(), replacementByte1);
      assertEquals(result.readByte(), replacementByte2);
      assertEquals(result.readByte(), 0x2);
  }

  [Test]
  public function findAndReplaceSecondByteInTwoBytesWithTwoBytes():void
  {
      var searchByte:int = 0x2;
      var replacementByte1:int = 0x3;
      var replacementByte2:int = 0x4;

      var haystack:ByteArray = new ByteArray();
      haystack.writeByte(0x1);
      haystack.writeByte(searchByte);

      var needle:ByteArray = new ByteArray();
      needle.writeByte(searchByte);

      var replacement:ByteArray = new ByteArray();
      replacement.writeByte(replacementByte1);
      replacement.writeByte(replacementByte2);

      var result:ByteArray = ByteArrayUtils.findAndReplaceFirstOccurrence(haystack, needle, replacement);
      assertEquals(result.length, (haystack.length - needle.length + replacement.length));
      assertEquals(result.readByte(), 0x1);
      assertEquals(result.readByte(), replacementByte1);
      assertEquals(result.readByte(), replacementByte2);
  }

  [Test]
  public function findAndReplaceMiddleByteInThreeBytesWithTwoBytes():void
  {
      var searchByte:int = 0x2;
      var replacementByte1:int = 0x4;
      var replacementByte2:int = 0x5;

      var haystack:ByteArray = new ByteArray();
      haystack.writeByte(0x1);
      haystack.writeByte(searchByte);
      haystack.writeByte(0x3);

      var needle:ByteArray = new ByteArray();
      needle.writeByte(searchByte);

      var replacement:ByteArray = new ByteArray();
      replacement.writeByte(replacementByte1);
      replacement.writeByte(replacementByte2);

      var result:ByteArray = ByteArrayUtils.findAndReplaceFirstOccurrence(haystack, needle, replacement);
      assertEquals(result.length, (haystack.length - needle.length + replacement.length));
      assertEquals(result.readByte(), 0x1);
      assertEquals(result.readByte(), replacementByte1);
      assertEquals(result.readByte(), replacementByte2);
      assertEquals(result.readByte(), 0x3);
  }

}
}