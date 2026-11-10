package com.muslimly.app

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.SystemClock
import android.util.TypedValue
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

/**
 * Prayer-times home-screen widget. Flutter only writes data (JSON in the
 * home_widget SharedPreferences); everything here is native and offline.
 *
 * Countdown is a system-rendered Chronometer, so nothing ticks per second.
 * The widget is redrawn at each prayer boundary by an AlarmManager alarm
 * (exact when permitted, inexact otherwise — then it may lag a few minutes).
 */
open class PrayerWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(ctx: Context, mgr: AppWidgetManager, ids: IntArray) {
        ids.forEach { render(ctx, mgr, it) }
        scheduleNextBoundary(ctx)
    }

    override fun onAppWidgetOptionsChanged(
        ctx: Context, mgr: AppWidgetManager, id: Int, newOptions: android.os.Bundle?,
    ) {
        render(ctx, mgr, id)
    }

    override fun onEnabled(ctx: Context) {
        scheduleNextBoundary(ctx)
    }

    override fun onDisabled(ctx: Context) {
        // Other size variants may still be on the home screen.
        if (allIds(ctx, AppWidgetManager.getInstance(ctx)).isEmpty()) {
            (ctx.getSystemService(Context.ALARM_SERVICE) as AlarmManager)
                .cancel(updatePendingIntent(ctx))
        }
    }

    override fun onReceive(ctx: Context, intent: Intent) {
        super.onReceive(ctx, intent)
        when (intent.action) {
            ACTION_UPDATE,
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED,
            Intent.ACTION_MY_PACKAGE_REPLACED -> {
                val mgr = AppWidgetManager.getInstance(ctx)
                val ids = allIds(ctx, mgr)
                if (ids.isNotEmpty()) {
                    ids.forEach { render(ctx, mgr, it) }
                    scheduleNextBoundary(ctx)
                }
            }
        }
    }

    companion object {
        const val ACTION_UPDATE = "com.muslimly.app.PRAYER_WIDGET_UPDATE"
        private const val PREFS = "HomeWidgetPreferences" // home_widget's file
        private const val KEY = "prayer_widget_json"
        private const val SETTINGS_KEY = "prayer_widget_settings"
        private val PROVIDERS = listOf(
            PrayerWidgetProvider::class.java,
            PrayerWidgetStripProvider::class.java,
            PrayerWidgetListProvider::class.java,
        )

        private fun allIds(ctx: Context, mgr: AppWidgetManager): IntArray =
            PROVIDERS.flatMap {
                mgr.getAppWidgetIds(ComponentName(ctx, it)).toList()
            }.toIntArray()

        private enum class Variant { SMALL, STRIP, LIST }

        private fun variantOf(mgr: AppWidgetManager, id: Int): Variant =
            when (mgr.getAppWidgetInfo(id)?.provider?.className) {
                PrayerWidgetStripProvider::class.java.name -> Variant.STRIP
                PrayerWidgetListProvider::class.java.name -> Variant.LIST
                else -> Variant.SMALL
            }

        private val COL_IDS = intArrayOf(R.id.col_0, R.id.col_1, R.id.col_2, R.id.col_3, R.id.col_4)
        private val CNAME_IDS = intArrayOf(R.id.cname_0, R.id.cname_1, R.id.cname_2, R.id.cname_3, R.id.cname_4)
        private val CTIME_IDS = intArrayOf(R.id.ctime_0, R.id.ctime_1, R.id.ctime_2, R.id.ctime_3, R.id.ctime_4)

        private val ROW_IDS = intArrayOf(
            R.id.row_0, R.id.row_1, R.id.row_2, R.id.row_3, R.id.row_4,
        )
        private val NAME_IDS = intArrayOf(
            R.id.name_0, R.id.name_1, R.id.name_2, R.id.name_3, R.id.name_4,
        )
        private val TIME_IDS = intArrayOf(
            R.id.time_0, R.id.time_1, R.id.time_2, R.id.time_3, R.id.time_4,
        )
        private val KEYS = listOf("fajr", "dhuhr", "asr", "maghrib", "isha")
        private val FALLBACK = mapOf(
            "fajr" to "Fajr", "dhuhr" to "Dhuhr", "asr" to "Asr",
            "maghrib" to "Maghrib", "isha" to "Isha",
        )

        private fun load(ctx: Context): PrayerWidgetData? =
            PrayerWidgetData.parse(
                ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(KEY, null),
            )

        // Small widget opens the prayer tab; medium (which shows ticks) opens
        // the tracker, where the check-in actually happens.
        private fun launchIntent(ctx: Context, medium: Boolean): PendingIntent =
            HomeWidgetLaunchIntent.getActivity(
                ctx,
                MainActivity::class.java,
                Uri.parse(if (medium) "muslimly://tracker" else "muslimly://prayer"),
            )

        private fun updatePendingIntent(ctx: Context): PendingIntent {
            val i = Intent(ctx, PrayerWidgetProvider::class.java).setAction(ACTION_UPDATE)
            return PendingIntent.getBroadcast(
                ctx, 0, i, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }

        private fun loadSettings(ctx: Context): PrayerWidgetSettings =
            PrayerWidgetSettings.parse(
                ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(SETTINGS_KEY, null),
            )

        private fun setSize(v: RemoteViews, id: Int, baseSp: Float, scale: Float) =
            v.setTextViewTextSize(id, TypedValue.COMPLEX_UNIT_SP, baseSp * scale)

        private fun setInfo(v: RemoteViews, id: Int, text: String, color: Int, baseSp: Float, scale: Float) {
            if (text.isEmpty()) {
                v.setViewVisibility(id, View.GONE)
            } else {
                v.setViewVisibility(id, View.VISIBLE)
                v.setTextViewText(id, text)
                v.setTextColor(id, color)
                setSize(v, id, baseSp, scale)
            }
        }

        fun render(ctx: Context, mgr: AppWidgetManager, id: Int) {
            val now = System.currentTimeMillis()
            val data = load(ctx)
            val st = loadSettings(ctx)
            val th = st.theme
            val k = st.textScale
            val variant = variantOf(mgr, id)
            val medium = variant == Variant.LIST // rows + tracker tap target
            val minHeightDp = mgr.getAppWidgetOptions(id)
                .getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 0)
            val views = RemoteViews(
                ctx.packageName,
                when (variant) {
                    Variant.SMALL -> R.layout.widget_prayer_small
                    Variant.STRIP -> R.layout.widget_prayer_strip
                    Variant.LIST -> R.layout.widget_prayer_medium
                },
            )
            views.setOnClickPendingIntent(R.id.widget_root, launchIntent(ctx, variant != Variant.SMALL))
            views.setInt(R.id.widget_bg, "setImageResource", th.bgRes)
            views.setInt(R.id.widget_bg, "setImageAlpha", st.opacity * 255 / 100)

            // Base text sizes per variant, scaled by the user's text-size choice.
            val (labelSp, nameSp, cdSp) = when (variant) {
                Variant.SMALL -> Triple(10f, 20f, 15f)
                Variant.STRIP -> Triple(9f, 15f, 12f)
                Variant.LIST -> Triple(10f, 20f, 16f)
            }
            setSize(views, R.id.next_label, labelSp, k)
            setSize(views, R.id.next_name, nameSp, k)
            setSize(views, R.id.countdown, cdSp, k)
            views.setTextColor(R.id.next_label, th.subtext)
            views.setTextColor(R.id.next_name, th.text)
            views.setTextColor(R.id.countdown, th.accent)

            if (medium) {
                views.setInt(R.id.widget_gear, "setColorFilter", th.text)
                views.setOnClickPendingIntent(
                    R.id.widget_gear,
                    HomeWidgetLaunchIntent.getActivity(
                        ctx, MainActivity::class.java, Uri.parse("muslimly://widget-settings"),
                    ),
                )
            }

            val next = data?.next(now)
            if (data == null || next == null) {
                // No data yet, or the cached week ran out: say so instead of
                // showing a stale countdown.
                views.setTextViewText(R.id.next_label, "")
                views.setTextViewText(
                    R.id.next_name,
                    data?.label("openApp", "") ?: ctx.getString(R.string.widget_open_app),
                )
                views.setViewVisibility(R.id.countdown, View.GONE)
                if (medium) {
                    ROW_IDS.forEach { views.setViewVisibility(it, View.GONE) }
                    views.setViewVisibility(R.id.info_date, View.GONE)
                    views.setViewVisibility(R.id.info_extra, View.GONE)
                }
                if (variant == Variant.STRIP) {
                    COL_IDS.forEach { views.setViewVisibility(it, View.GONE) }
                    views.setViewVisibility(R.id.info_line, View.GONE)
                }
                mgr.updateAppWidget(id, views)
                return
            }

            val name = data.label(next.key, FALLBACK[next.key] ?: next.key)
            views.setTextViewText(
                R.id.next_label,
                data.label("next", "Next").uppercase(Locale.getDefault()),
            )
            views.setTextViewText(R.id.next_name, name)
            views.setViewVisibility(R.id.countdown, View.VISIBLE)
            val base = SystemClock.elapsedRealtime() + (next.startMs - now)
            views.setChronometer(R.id.countdown, base, null, true)
            if (Build.VERSION.SDK_INT >= 24) {
                views.setChronometerCountDown(R.id.countdown, true)
            }

            val timeFmt = SimpleDateFormat("HH:mm", Locale.getDefault())
            val day = data.day(now)
            val city = data.cityName.trim()
            val doneCount = day?.prayers?.count { it.done } ?: 0
            val total = day?.prayers?.size ?: 0
            val progress = if (st.showProgress && total > 0) {
                val parts = mutableListOf("$doneCount/$total ${data.label("done", "done")}")
                data.current(now)?.let {
                    parts += "${data.label("endsAt", "Ends")} ${timeFmt.format(Date(it.endMs))}"
                }
                parts.joinToString(" \u00B7 ")
            } else ""

            if (variant == Variant.LIST) {
                val dateParts = listOfNotNull(
                    day?.gregorian?.takeIf { st.showGregorian && it.isNotEmpty() },
                    day?.hijri?.takeIf { st.showHijri && it.isNotEmpty() },
                )
                setInfo(views, R.id.info_date, dateParts.joinToString(" \u00B7 "), th.subtext, 11f, k)
                val extra = listOfNotNull(
                    city.takeIf { st.showLocation && it.isNotEmpty() }?.let { "\uD83D\uDCCD $it" },
                    progress.takeIf { it.isNotEmpty() },
                )
                setInfo(views, R.id.info_extra, extra.joinToString(" \u00B7 "), th.subtext, 11f, k)
            }
            if (variant == Variant.STRIP) {
                val parts = listOfNotNull(
                    day?.gregorianShort?.takeIf { st.showGregorian && it.isNotEmpty() },
                    day?.hijri?.takeIf { st.showHijri && it.isNotEmpty() },
                    city.takeIf { st.showLocation && it.isNotEmpty() },
                )
                // One-cell-high strips have no room for a fourth line.
                val text = if (minHeightDp >= 90) parts.joinToString(" \u00B7 ") else ""
                setInfo(views, R.id.info_line, text, th.subtext, 9f, k)
            }

            fun rowColor(p: WidgetPrayer): Int = when {
                p.startMs == next.startMs -> th.accent
                p.done -> th.done
                else -> th.text
            }

            if (medium) {
                KEYS.forEachIndexed { i, key ->
                    val p = day?.prayers?.firstOrNull { it.key == key }
                    if (p == null) {
                        views.setViewVisibility(ROW_IDS[i], View.GONE)
                    } else {
                        views.setViewVisibility(ROW_IDS[i], View.VISIBLE)
                        val label = data.label(key, FALLBACK[key] ?: key)
                        views.setTextViewText(NAME_IDS[i], if (p.done) "\u2713 $label" else label)
                        views.setTextViewText(TIME_IDS[i], timeFmt.format(Date(p.startMs)))
                        val highlighted = p.startMs == next.startMs
                        views.setInt(
                            ROW_IDS[i], "setBackgroundResource",
                            if (highlighted) R.drawable.widget_row_next else R.drawable.widget_row_plain,
                        )
                        views.setTextColor(NAME_IDS[i], rowColor(p))
                        views.setTextColor(TIME_IDS[i], rowColor(p))
                        setSize(views, NAME_IDS[i], 14f, k)
                        setSize(views, TIME_IDS[i], 14f, k)
                    }
                }
            }
            if (variant == Variant.STRIP) {
                KEYS.forEachIndexed { i, key ->
                    val p = day?.prayers?.firstOrNull { it.key == key }
                    if (p == null) {
                        views.setViewVisibility(COL_IDS[i], View.GONE)
                    } else {
                        views.setViewVisibility(COL_IDS[i], View.VISIBLE)
                        val label = data.label(key, FALLBACK[key] ?: key)
                        views.setTextViewText(CNAME_IDS[i], if (p.done) "\u2713 $label" else label)
                        views.setTextViewText(CTIME_IDS[i], timeFmt.format(Date(p.startMs)))
                        views.setTextColor(CNAME_IDS[i], rowColor(p))
                        views.setTextColor(CTIME_IDS[i], rowColor(p))
                        views.setInt(
                            COL_IDS[i], "setBackgroundResource",
                            if (p.startMs == next.startMs) R.drawable.widget_row_next else R.drawable.widget_row_plain,
                        )
                    }
                }
            }
            mgr.updateAppWidget(id, views)
        }

        /** Re-arms one alarm at the next prayer start or local midnight. */
        fun scheduleNextBoundary(ctx: Context) {
            val now = System.currentTimeMillis()
            val cal = Calendar.getInstance().apply {
                timeInMillis = now
                add(Calendar.DAY_OF_YEAR, 1)
                set(Calendar.HOUR_OF_DAY, 0); set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 5); set(Calendar.MILLISECOND, 0)
            }
            var at = cal.timeInMillis // midnight: flips the medium widget's day
            load(ctx)?.next(now)?.let { if (it.startMs < at) at = it.startMs }

            val am = ctx.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val pi = updatePendingIntent(ctx)
            val canExact = Build.VERSION.SDK_INT < Build.VERSION_CODES.S || am.canScheduleExactAlarms()
            try {
                if (canExact) am.setExactAndAllowWhileIdle(AlarmManager.RTC, at, pi)
                else am.setAndAllowWhileIdle(AlarmManager.RTC, at, pi) // may lag a few minutes
            } catch (e: SecurityException) {
                am.setAndAllowWhileIdle(AlarmManager.RTC, at, pi)
            }
        }
    }
}
