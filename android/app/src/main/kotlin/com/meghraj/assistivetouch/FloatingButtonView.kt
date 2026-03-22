package com.meghraj.assistivetouch

import android.animation.ValueAnimator
import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.view.GestureDetector
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

    private val gestureDetector = GestureDetector(context, object : GestureDetector.SimpleOnGestureListener() {
        override fun onSingleTapConfirmed(e: MotionEvent): Boolean {
            val action = getGestureAction("singleTap", "open_menu")
            ActionExecutor.execute(context, action)
            return true
        }

        override fun onDoubleTap(e: MotionEvent): Boolean {
            val action = getGestureAction("doubleTap", "recents")
            ActionExecutor.execute(context, action)
            return true
        }

        override fun onLongPress(e: MotionEvent) {
            val action = getGestureAction("longPress", "none")
            ActionExecutor.execute(context, action)
        }
    })

    private fun getGestureAction(key: String, default: String): String {
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        return prefs.getString("flutter.gesture.$key", default) ?: default
    }

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
                "circle" -> setImageResource(android.R.drawable.presence_online)
                "star" -> setImageResource(android.R.drawable.btn_star_big_on)
                "default" -> setImageResource(android.R.drawable.ic_menu_add)
                else -> setImageResource(android.R.drawable.ic_menu_add)
            }
            alpha = opacity
            
            val shape = GradientDrawable()
            shape.shape = GradientDrawable.OVAL
            shape.setColor(Color.parseColor("#3B82F6"))
            background = shape
        }

        addView(iconView, LayoutParams(sizePx, sizePx))

        setOnTouchListener { _, event ->
            // Route structural taps sequentially into GestureDetector
            gestureDetector.onTouchEvent(event)

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

                    // Touch slop explicitly mapped to 10 pixels for drag distinction securely
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
                    }
                    true
                }
                else -> false
            }
        }
    }

    private fun snapToEdge() {
        val screenWidth = context.resources.displayMetrics.widthPixels
        val currentX = layoutParams.x

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
        animator.addListener(object : android.animation.AnimatorListenerAdapter() {
            override fun onAnimationEnd(animation: android.animation.Animator) {
                val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                prefs.edit()
                    .putFloat("flutter.overlay_x", layoutParams.x.toFloat())
                    .putFloat("flutter.overlay_y", layoutParams.y.toFloat())
                    .apply()
            }
        })
        animator.start()
    }
}
