package com.meghraj.assistivetouch

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.view.HapticFeedbackConstants
import android.animation.ValueAnimator
import android.widget.FrameLayout
import android.widget.GridLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import java.util.Locale
import kotlin.math.roundToInt

class PanelOverlayView(context: Context, private val onClose: () -> Unit) : FrameLayout(context) {

    private var currentPage = 0
    private val grid: GridLayout
    private val dotsContainer: LinearLayout
    private val itemSize: Int
    private val margin: Int

    init {
        setBackgroundColor(Color.parseColor("#99000000"))
        setOnClickListener { onClose() }

        val panelContainer = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            val shape = GradientDrawable().apply {
                setColor(Color.parseColor("#0F172A"))
                cornerRadius = 48f
            }
            background = shape
            setPadding(48, 48, 48, 48)
            setOnClickListener { } // Consume taps inside panel
        }

        grid = GridLayout(context).apply {
            columnCount = 3
            rowCount = 3
            alignmentMode = GridLayout.ALIGN_BOUNDS
        }

        dotsContainer = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER
            setPadding(0, 32, 0, 0)
        }

        val density = context.resources.displayMetrics.density
        itemSize = (80 * density).roundToInt()
        margin = (8 * density).roundToInt()

        renderPage()

        panelContainer.addView(grid)
        panelContainer.addView(dotsContainer)

        val containerParams = LayoutParams(
            ViewGroup.LayoutParams.WRAP_CONTENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        ).apply {
            gravity = Gravity.CENTER
        }
        
        addView(panelContainer, containerParams)
        
        panelContainer.alpha = 0f
        panelContainer.scaleX = 0.8f
        panelContainer.scaleY = 0.8f
        val animator = ValueAnimator.ofFloat(0f, 1f)
        animator.duration = 250
        animator.interpolator = android.view.animation.OvershootInterpolator(1.2f)
        animator.addUpdateListener { anim ->
            val v = anim.animatedValue as Float
            panelContainer.alpha = v
            panelContainer.scaleX = 0.8f + (0.2f * v)
            panelContainer.scaleY = 0.8f + (0.2f * v)
        }
        animator.start()
    }

    private fun renderPage() {
        grid.removeAllViews()
        dotsContainer.removeAllViews()

        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val prefix = if (currentPage == 0) "flutter.panel.main" else "flutter.panel.setting"

        for (i in 0 until 9) {
            val defaultVal = if (currentPage == 0) {
                listOf("home", "back", "recents", "notifications", "power_dialog", "quick_settings", "none", "none", "open_settings").getOrElse(i) { "none" }
            } else {
                listOf("volume_up", "volume_down", "lock_screen", "flashlight", "screenshot", "none", "none", "none", "none").getOrElse(i) { "none" }
            }
            val actionId = prefs.getString("${prefix}_$i", defaultVal) ?: defaultVal
            val item = createGridItem(actionId, itemSize)
            
            val params = GridLayout.LayoutParams().apply {
                width = itemSize
                height = itemSize
                setMargins(margin, margin, margin, margin)
                setGravity(Gravity.CENTER)
            }
            grid.addView(item, params)
        }

        for (i in 0..1) {
            val dot = View(context).apply {
                val shape = GradientDrawable().apply {
                    shape = GradientDrawable.OVAL
                    setColor(if (i == currentPage) Color.WHITE else Color.parseColor("#88FFFFFF"))
                }
                background = shape
                setOnClickListener {
                    if (currentPage != i) {
                        currentPage = i
                        renderPage()
                    }
                }
            }
            
            val size = if (i == currentPage) 24 else 16
            val lp = LinearLayout.LayoutParams(size, size).apply {
                setMargins(12, 0, 12, 0)
            }
            dotsContainer.addView(dot, lp)
        }
    }

    private fun createGridItem(actionId: String, size: Int): View {
        val container = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            val shape = GradientDrawable().apply {
                setColor(Color.parseColor("#33FFFFFF"))
                cornerRadius = 24f
            }
            background = shape
            
            if (actionId != "none") {
                setOnClickListener {
                    it.performHapticFeedback(HapticFeedbackConstants.VIRTUAL_KEY)
                    onClose()
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
                "volume_up", "volume_down" -> android.R.drawable.ic_lock_silent_mode_off
                "lock_screen" -> android.R.drawable.ic_lock_lock
                "flashlight" -> android.R.drawable.ic_menu_camera
                "screenshot" -> android.R.drawable.ic_menu_gallery
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
