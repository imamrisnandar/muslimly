package com.muslimly.app

import org.json.JSONObject

/** Colours of one widget theme. Ids match WidgetThemeId in Dart. */
class WidgetTheme(
    val id: String,
    val bgRes: Int,
    val text: Int,
    val subtext: Int,
    val accent: Int,
    val done: Int,
) {
    companion object {
        private val THEMES = mapOf(
            "emerald" to WidgetTheme("emerald", R.drawable.widget_bg_emerald, 0xFFFFFFFF.toInt(), 0xB3FFFFFF.toInt(), 0xFFFFD54F.toInt(), 0xFF7FE0A8.toInt()),
            "ocean" to WidgetTheme("ocean", R.drawable.widget_bg_ocean, 0xFFFFFFFF.toInt(), 0xB3FFFFFF.toInt(), 0xFFFFD54F.toInt(), 0xFF7FE0A8.toInt()),
            "violet" to WidgetTheme("violet", R.drawable.widget_bg_violet, 0xFFFFFFFF.toInt(), 0xB3FFFFFF.toInt(), 0xFFFFCA28.toInt(), 0xFF7FE0A8.toInt()),
            "amber" to WidgetTheme("amber", R.drawable.widget_bg_amber, 0xFFFFFFFF.toInt(), 0xB3FFFFFF.toInt(), 0xFFFFE082.toInt(), 0xFF7FE0A8.toInt()),
            "light" to WidgetTheme("light", R.drawable.widget_bg_light, 0xFF1B2B2A.toInt(), 0x991B2B2A.toInt(), 0xFFB26A00.toInt(), 0xFF2E7D32.toInt()),
        )

        fun byId(id: String?): WidgetTheme = THEMES[id] ?: THEMES.getValue("emerald")
    }
}

/** User options written by Dart (widget_settings.dart). Unknown = default. */
data class PrayerWidgetSettings(
    val theme: WidgetTheme = WidgetTheme.byId(null),
    val opacity: Int = 100,
    val textScale: Float = 1f,
    val showHijri: Boolean = true,
    val showGregorian: Boolean = true,
    val showLocation: Boolean = true,
    val showProgress: Boolean = true,
) {
    companion object {
        fun parse(json: String?): PrayerWidgetSettings {
            if (json.isNullOrEmpty()) return PrayerWidgetSettings()
            return try {
                val o = JSONObject(json)
                PrayerWidgetSettings(
                    theme = WidgetTheme.byId(o.optString("theme")),
                    opacity = o.optInt("opacity", 100).coerceIn(30, 100),
                    textScale = when (o.optInt("textSize", 1)) {
                        0 -> 0.88f
                        2 -> 1.15f
                        else -> 1f
                    },
                    showHijri = o.optBoolean("showHijri", true),
                    showGregorian = o.optBoolean("showGregorian", true),
                    showLocation = o.optBoolean("showLocation", true),
                    showProgress = o.optBoolean("showProgress", true),
                )
            } catch (e: Exception) {
                PrayerWidgetSettings()
            }
        }
    }
}
