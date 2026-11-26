package com.sgcodexs.menuaim

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.graphics.Path
import android.view.accessibility.AccessibilityEvent
import kotlin.math.abs
import kotlin.math.roundToInt

class TouchService : AccessibilityService() {
    var sensitivityMultiplier: Float = 1.8f
    var isAntiShakeEnabled: Boolean = true
    var isHeadLockEnabled: Boolean = true
    var yAxisMultiplier: Float = 1.25f

    companion object {
        private var instance: TouchService? = null
        fun getInstance(): TouchService? = instance
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
    }

    override fun onDestroy() {
        instance = null
        super.onDestroy()
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {}
    override fun onInterrupt() {}

    fun performSmartDrag(startX: Float, startY: Float, endX: Float, endY: Float) {
        var deltaX = endX - startX
        var deltaY = endY - startY

        if (isAntiShakeEnabled) {
            if (abs(deltaX) < 5 && abs(deltaY) < 5) return
            deltaX = (deltaX * 0.95f).roundToInt().toFloat()
            deltaY = (deltaY * 0.95f).roundToInt().toFloat()
        }

        deltaX *= sensitivityMultiplier
        deltaY *= sensitivityMultiplier

        if (isHeadLockEnabled && deltaY < 0) {
            deltaY *= yAxisMultiplier
        }

        val path = Path()
        path.moveTo(startX, startY)
        path.lineTo(startX + deltaX, startY + deltaY)

        val gesture = GestureDescription.Builder()
            .addStroke(GestureDescription.StrokeDescription(path, 0, 80L))
            .build()
        dispatchGesture(gesture, null, null)
    }
}
