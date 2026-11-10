package com.muslimly.app

import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

data class WidgetPrayer(
    val key: String,
    val startMs: Long,
    val endMs: Long,
    val done: Boolean = false,
)

data class WidgetDay(
    val date: String,
    val prayers: List<WidgetPrayer>,
    val hijri: String = "",
    val gregorian: String = "",
    val gregorianShort: String = "",
)

/**
 * Parsed form of the JSON written by Dart (see widget_payload_builder.dart).
 * Pure logic only — no Android UI — so "which prayer is next" is decided at
 * render time from absolute epochs, never from stored state.
 */
class PrayerWidgetData(
    val cityName: String,
    val labels: Map<String, String>,
    val days: List<WidgetDay>,
) {
    fun label(key: String, fallback: String): String = labels[key] ?: fallback

    /** Every prayer of every day, in time order. */
    fun all(): List<WidgetPrayer> =
        days.flatMap { it.prayers }.sortedBy { it.startMs }

    /** First prayer starting strictly after [nowMs], or null when data ran out. */
    fun next(nowMs: Long): WidgetPrayer? = all().firstOrNull { it.startMs > nowMs }

    /** The day whose date matches the local date of [nowMs]. */
    fun day(nowMs: Long): WidgetDay? {
        val fmt = SimpleDateFormat("yyyy-MM-dd", Locale.US)
        val date = fmt.format(Date(nowMs))
        return days.firstOrNull { it.date == date }
    }

    /** The five prayers whose day matches the local date of [nowMs]. */
    fun today(nowMs: Long): List<WidgetPrayer>? = day(nowMs)?.prayers

    /** The prayer whose window contains [nowMs] (null between data gaps). */
    fun current(nowMs: Long): WidgetPrayer? =
        all().firstOrNull { it.startMs <= nowMs && nowMs < it.endMs }

    companion object {
        fun parse(json: String?): PrayerWidgetData? {
            if (json.isNullOrEmpty()) return null
            return try {
                val o = JSONObject(json)
                val labelsObj = o.optJSONObject("labels")
                val labels = mutableMapOf<String, String>()
                labelsObj?.keys()?.forEach { labels[it] = labelsObj.getString(it) }
                val daysArr = o.getJSONArray("days")
                val days = (0 until daysArr.length()).map { i ->
                    val d = daysArr.getJSONObject(i)
                    val ps = d.getJSONArray("prayers")
                    WidgetDay(
                        d.getString("date"),
                        prayers = (0 until ps.length()).map { j ->
                            val p = ps.getJSONObject(j)
                            WidgetPrayer(
                                p.getString("key"),
                                p.getLong("startEpochMs"),
                                p.getLong("endEpochMs"),
                                p.optBoolean("done", false),
                            )
                        },
                        hijri = d.optString("hijri"),
                        gregorian = d.optString("gregorian"),
                        gregorianShort = d.optString("gregorianShort"),
                    )
                }
                PrayerWidgetData(o.optString("cityName"), labels, days)
            } catch (e: Exception) {
                null
            }
        }
    }
}
