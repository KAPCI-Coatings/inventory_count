package com.amin.zebra_datawedge

import android.content.Intent
import android.os.Bundle
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import kotlin.test.assertContentEquals
import kotlin.test.assertEquals
import kotlin.test.assertNotEquals
import kotlin.test.assertTrue

@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE)
class ZebraDatawedgePluginTest {
  private val plugin = ZebraDatawedgePlugin()

  @Test
  fun `nextCommandId increments sequence`() {
    val first = invokeNextCommandId("TAG")
    val second = invokeNextCommandId("TAG")

    assertTrue(first.startsWith("TAG-"))
    assertTrue(second.startsWith("TAG-"))
    assertNotEquals(first, second)

    val firstSequence = first.substringAfterLast('-').toInt()
    val secondSequence = second.substringAfterLast('-').toInt()
    assertEquals(firstSequence + 1, secondSequence)
  }

  @Test
  fun `mapToBundle and bundleToMap preserve nested payload structures`() {
    val original = mapOf<String, Any?>(
      "string" to "value",
      "int" to 2,
      "bool" to true,
      "nested" to mapOf("mode" to "fast"),
      "ints" to listOf(1, 2, 3),
      "mixed" to listOf("a", 1),
    )

    val bundle = invokeMapToBundle(original)
    val roundTrip = invokeBundleToMap(bundle)

    assertEquals("value", roundTrip["string"])
    assertEquals(2, roundTrip["int"])
    assertEquals(true, roundTrip["bool"])

    val nested = roundTrip["nested"] as Map<*, *>
    assertEquals("fast", nested["mode"])

    assertEquals(listOf(1, 2, 3), roundTrip["ints"])
    assertEquals(listOf("a", "1"), roundTrip["mixed"])
  }

  @Test
  fun `putIntentExtra writes map and list payloads into intent extras`() {
    val intent = Intent("com.example.TEST")

    invokePutIntentExtra(
      intent,
      "payload",
      mapOf(
        "mode" to "fast",
        "levels" to listOf(1, 2),
      ),
    )
    invokePutIntentExtra(
      intent,
      "items",
      listOf(
        mapOf("id" to 1),
        mapOf("id" to 2),
      ),
    )

    val payload = intent.getBundleExtra("payload")
    assertEquals("fast", payload?.getString("mode"))
    assertContentEquals(intArrayOf(1, 2), payload?.getIntegerArrayList("levels")?.toIntArray())

    @Suppress("DEPRECATION")
    val items = intent.getParcelableArrayListExtra<Bundle>("items")
    assertEquals(2, items?.size)
    assertEquals(1, items?.get(0)?.getInt("id"))
    assertEquals(2, items?.get(1)?.getInt("id"))

    val payloadText = invokeBundleToString(payload)
    assertTrue(payloadText.contains("mode=fast"))
    assertTrue(payloadText.contains("levels="))
    assertTrue(payloadText.contains("1"))
    assertTrue(payloadText.contains("2"))
  }

  private fun invokeNextCommandId(prefix: String): String {
    val method = ZebraDatawedgePlugin::class.java.getDeclaredMethod(
      "nextCommandId",
      String::class.java,
    )
    method.isAccessible = true
    return method.invoke(plugin, prefix) as String
  }

  private fun invokeMapToBundle(value: Map<*, *>): Bundle {
    val method = ZebraDatawedgePlugin::class.java.getDeclaredMethod(
      "mapToBundle",
      Map::class.java,
    )
    method.isAccessible = true
    return method.invoke(plugin, value) as Bundle
  }

  @Suppress("UNCHECKED_CAST")
  private fun invokeBundleToMap(bundle: Bundle?): Map<String, Any?> {
    val method = ZebraDatawedgePlugin::class.java.getDeclaredMethod(
      "bundleToMap",
      Bundle::class.java,
    )
    method.isAccessible = true
    return method.invoke(plugin, bundle) as Map<String, Any?>
  }

  private fun invokePutIntentExtra(intent: Intent, key: String, value: Any?) {
    val method = ZebraDatawedgePlugin::class.java.getDeclaredMethod(
      "putIntentExtra",
      Intent::class.java,
      String::class.java,
      Any::class.java,
    )
    method.isAccessible = true
    method.invoke(plugin, intent, key, value)
  }

  private fun invokeBundleToString(bundle: Bundle?): String {
    val method = ZebraDatawedgePlugin::class.java.getDeclaredMethod(
      "bundleToString",
      Bundle::class.java,
    )
    method.isAccessible = true
    return method.invoke(plugin, bundle) as String
  }
}
