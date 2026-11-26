package com.sgcodexs.menuaim

import android.app.Service
import android.content.Intent
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.os.IBinder
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout

class AimOverlayService : Service() {
    private lateinit var windowManager: WindowManager
    private lateinit var overlayView: FrameLayout

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        showOverlay()
    }

    private fun showOverlay() {
        overlayView = FrameLayout(this)
        val crosshair = object : View(this) {
            override fun onDraw(canvas: Canvas) {
                super.onDraw(canvas)
                val paint = Paint().apply {
                    color = Color.RED
                    strokeWidth = 3f
                    style = Paint.Style.STROKE
                }
                val cx = width / 2f
                val cy = height / 2f
                val gap = 20f
                val len = 40f
                canvas.drawLine(cx, cy - gap, cx, cy - gap - len, paint)
                canvas.drawLine(cx, cy + gap, cx, cy + gap + len, paint)
                canvas.drawLine(cx - gap, cy, cx - gap - len, cy, paint)
                canvas.drawLine(cx + gap, cy, cx + gap + len, cy, paint)
                canvas.drawCircle(cx, cy, 3f, paint)
            }
        }
        overlayView.addView(crosshair, FrameLayout.LayoutParams(300, 300))
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE,
            android.graphics.PixelFormat.TRANSLUCENT
        )
        params.gravity = android.view.Gravity.CENTER
        windowManager.addView(overlayView, params)
    }

    override fun onDestroy() {
        if (::overlayView.isInitialized) windowManager.removeView(overlayView)
        super.onDestroy()
    }
    override fun onBind(intent: Intent?): IBinder? = null
}
