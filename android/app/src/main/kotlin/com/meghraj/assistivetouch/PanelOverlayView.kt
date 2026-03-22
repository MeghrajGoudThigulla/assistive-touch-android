package com.meghraj.assistivetouch

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.GridLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import java.util.Locale
import kotlin.math.roundToInt

class PanelOverlayView(context: Context, private val onClose: () -> Unit) : FrameLayout(context) {

    private val defaultActions = listOf(
        "home", "back", "recents",
        "notifications", "power_dialog", "quick_settings",
        "none", "none", "open_settings"
    )

    init {
        // Full screen dim overlay
        setBackgroundColor(Color.parseColor("#99000000"))
        
        // Touch outside to confidently close the panel
        setOnClickListener {
            onClose()
        }

        val panelContainer = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            val shape = GradientDrawable().apply {
                setColor(Color.parseColor("#0F172A")) // PRD Main Slate 900 backdrop
                cornerRadius = 48f
            }
            background = shape
            setPadding(48, 48, 48, 48)
            
            // Intercept clicks to prevent auto-closing when clicking the tray
            setOnClickListener { }
        }

        val grid = GridLayout(context).apply {
            columnCount = 3
            rowCount = 3
            alignmentMode = GridLayout.ALIGN_BOUNDS
        }

        val density = context.resources.displayMetrics.density
        val itemSize = (80 * density).roundToInt()
        val margin = (8 * density).roundToInt()

        // MVP safely falls back to standard array to abstract Flutter's JSON-list storage quirks
        val actions = defaultActions

        for (i in 0 until 9) {
            val actionId = actions.getOrNull(i) ?: "none"
            val item = createGridItem(actionId, itemSize)
            
            val params = GridLayout.LayoutParams().apply {
                width = itemSize
                height = itemSize
                setMargins(margin, margin, margin, margin)
                setGravity(Gravity.CENTER)
            }
            grid.addView(item, params)
        }

        panelContainer.addView(grid)

        val containerParams = LayoutParams(
            ViewGroup.LayoutParams.WRAP_CONTENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        ).apply {
            gravity = Gravity.CENTER
        }
        
        addView(panelContainer, containerParams)
    }

    private fun createGridItem(actionId: String, size: Int): View {
        val container = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            val shape = GradientDrawable().apply {
                setColor(Color.parseColor("#33FFFFFF")) // Ghost effect per PRD
                cornerRadius = 24f
            }
            background = shape
            
            if (actionId != "none") {
                setOnClickListener {
                    onClose() // Disappear explicitly when triggering action
                    ActionExecutor.execute(context, actionId)
                }
            }
        }

        val icon = ImageView(context).apply {
            val resId = when(actionId) {
                "home" -> android.R.drawable.ic_menu_myplaces
                "back" -> android.R.drawable.ic_menu_revert
                "recents" -> android.R.drawable.ic_menu_recent_history
                "notifications" -> android.R.drawable.ic_menu_sort_by_size
                "power_dialog" -> android.R.drawable.ic_lock_power_off
                "quick_settings" -> android.R.drawable.ic_menu_manage
                "open_settings" -> android.R.drawable.ic_menu_preferences
                else -> android.R.color.transparent
            }
            setImageResource(resId)
            setColorFilter(Color.WHITE)
        }
        
        val lp = LinearLayout.LayoutParams(size / 3, size / 3)
        container.addView(icon, lp)

        val label = TextView(context).apply {
            text = actionId.replace("_", " ").replaceFirstChar { if (it.isLowerCase()) it.titlecase(Locale.ROOT) else it.toString() }
            setTextColor(Color.WHITE)
            textSize = 10f
            gravity = Gravity.CENTER
            setPadding(0, 16, 0, 0)
        }
        
        if (actionId != "none") {
            container.addView(label)
        }

        return container
    }
}
