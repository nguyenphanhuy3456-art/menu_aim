package com.sgcodexs.menuaim

import android.content.Intent
import android.net.Uri
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.view.WindowManager
import android.app.ActivityManager
import android.content.Context

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.sgcodexs.menuaim/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkOverlayPermission" -> result.success(Settings.canDrawOverlays(this))
                "requestOverlayPermission" -> {
                    if (!Settings.canDrawOverlays(this)) {
                        val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName"))
                        startActivity(intent)
                    }
                    result.success(true)
                }
                "startOverlay" -> {
                    if (Settings.canDrawOverlays(this)) {
                        startService(Intent(this, AimOverlayService::class.java))
                        result.success(true)
                    } else result.success(false)
                }
                "stopOverlay" -> {
                    stopService(Intent(this, AimOverlayService::class.java))
                    result.success(true)
                }
                "startVpn" -> {
                    val prepareIntent = android.net.VpnService.prepare(this)
                    if (prepareIntent != null) {
                        startActivityForResult(prepareIntent, 1)
                    } else {
                        onActivityResult(1, RESULT_OK, null)
                    }
                    result.success(true)
                }
                "sendToV2rayNG" -> {
                    val config = call.argument<String>("config") ?: ""
                    try {
                        val intent = Intent(Intent.ACTION_VIEW)
                        intent.setPackage("com.v2ray.ang")
                        intent.data = Uri.parse(config)
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) { result.success(false) }
                }
                "updateAimConfig" -> {
                    val sens = call.argument<Double>("sensitivity")?.toFloat() ?: 1.8f
                    val yMulti = call.argument<Double>("yMultiplier")?.toFloat() ?: 1.25f
                    TouchService.getInstance()?.let {
                        it.sensitivityMultiplier = sens
                        it.yAxisMultiplier = yMulti
                    }
                    result.success(true)
                }
                "toggleAntiban" -> {
                    val enable = call.argument<Boolean>("enable") ?: true
                    val intent = Intent(this, BridgeVpnService::class.java)
                    intent.putExtra("antiban", enable)
                    startService(intent)
                    result.success(true)
                }
                "hideApp" -> {
                    val enable = call.argument<Boolean>("enable") ?: true
                    if (enable) {
                        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                        activityManager.appTasks.forEach { it.setExclusionFromRecents(true) }
                    }
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 1 && resultCode == RESULT_OK) {
            startService(Intent(this, BridgeVpnService::class.java))
        }
    }
}
