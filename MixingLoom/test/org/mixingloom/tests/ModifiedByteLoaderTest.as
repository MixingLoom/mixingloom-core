/**
 * Created by IntelliJ IDEA.
 * User: James Ward <james@jamesward.org>
 * Date: 3/24/11
 * Time: 2:03 PM
 */
package org.mixingloom.tests
{

import org.flexunit.Assert;
import org.mixingloom.SwfContext;
import org.mixingloom.byteLoader.ModifiedByteLoader;

public class ModifiedByteLoaderTest
{

  [Test]
  public function applyModifications()
  {
    var modifiedByteLoader:ModifiedByteLoader = new ModifiedByteLoader();
    modifiedByteLoader.notifier = new MockPatchNotifier();
    modifiedByteLoader.applyModificiations(new SwfContext());
    Assert.assertTrue(true);
  }

}
}