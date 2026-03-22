package com.meghraj.assistivetouch

import android.animation.ValueAnimator
import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.view.MotionEvent
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.ImageView
import kotlin.math.abs
import kotlin.math.roundToInt

@SuppressLint("ViewConstructor")
class FloatingButtonView(
    context: Context,
    private val windowManager: WindowManager,
    private val layoutParams: WindowManager.LayoutParams
) : FrameLayout(context) {

    private val iconView: ImageView

    private var initialX = 0
    private var initialY = 0
    private var initialTouchX = 0f
    private var initialTouchY = 0f
    private var isDragging = false

    init {
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

        val panelSizeNum = prefs.all["flutter.panel_size"] as? Number ?: 50.0
        val panelOpacityNum = prefs.all["flutter.panel_opacity"] as? Number ?: 0.8
        
        val sizeDp = panelSizeNum.toFloat()
        val opacity = panelOpacityNum.toFloat()
        
        val iconId = prefs.getString("flutter.floating_icon_id", "default") ?: "default"

        val density = context.resources.displayMetrics.density
        val sizePx = (sizeDp * density).roundToInt()

        iconView = ImageView(context).apply {
            when(iconId) {
                "circle" -> setImageResource(android.R.drawable.presence_online) // Built-in primitive proxy
                "star" -> setImageResource(android.R.drawable.btn_star_big_on)
                "default" -> setImageResource(android.R.drawable.ic_menu_add)
                else -> setImageResource(android.R.drawable.ic_menu_add)
            }
            alpha = opacity
            
            val shape = GradientDrawable()
            shape.shape = GradientDrawable.OVAL
            shape.setColor(Color.parseColor("#3B82F6")) // PRD strict Accent Blue
            background = shape
        }

        addView(iconView, LayoutParams(sizePx, sizePx))

        setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    initialX = layoutParams.x
                    initialY = layoutParams.y
                    initialTouchX = event.rawX
                    initialTouchY = event.rawY
                    isDragging = false
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    val dx = event.rawX - initialTouchX
                    val dy = event.rawY - initialTouchY

                    if (abs(dx) > 10 || abs(dy) > 10) {
                        isDragging = true
                    }

                    if (isDragging) {
                        layoutParams.x = initialX + dx.toInt()
                        layoutParams.y = initialY + dy.toInt()
                        windowManager.updateViewLayout(this@FloatingButtonView, layoutParams)
                    }
                    true
                }
                MotionEvent.ACTION_UP -> {
                    if (isDragging) {
                        snapToEdge()
                    } else {
                        performClick()
                    }
                    true
                }
                else -> false
            }
        }
    }

    override fun performClick(): Boolean {
        super.performClick()
        // Phase 3: Open Customize Panel. For now, testing the channel response stream.
        GlobalEventStream.sendEvent(mapOf("event" to "buttonClicked"))
        return true
    }

    private fun snapToEdge() {
        val screenWidth = context.resources.displayMetrics.widthPixels
        val currentX = layoutParams.x

        // Evaluate snap target (0 = left, screenWidth = right)
        val targetX = if (currentX + (width / 2) < screenWidth / 2) {
            0
        } else {
            screenWidth - width
        }

        val animator = ValueAnimator.ofInt(currentX, targetX)
        animator.duration = 200
        animator.addUpdateListener { animation ->
            layoutParams.x = animation.animatedValue as Int
            windowManager.updateViewLayout(this@FloatingButtonView, layoutParams)
        }
        animator.start()
    }
}
