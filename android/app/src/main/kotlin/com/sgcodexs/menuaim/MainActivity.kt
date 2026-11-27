package com.sgcodexs.menuaim

import android.content.Intent
import android.net.Uri
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.view.WindowManager

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.sgcodexs.menuaim/native"
    private val VPN_REQUEST_CODE = 1

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkOverlayPermission" -> result.success(Settings.canDrawOverlays(this))
                "requestOverlayPermission" -> {
                    // Ép hệ thống mở bảng xin quyền Overlay
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
                    // Ép hệ thống hiện bảng xin quyền VPN
                    val prepareIntent = android.net.VpnService.prepare(this)
                    if (prepareIntent != null) {
                        startActivityForResult(prepareIntent, VPN_REQUEST_CODE)
                    } else {
                        // Nếu đã có quyền thì chạy luôn
                        startService(Intent(this, BridgeVpnService::class.java))
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
                    }
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        // Nếu người dùng bấm OK ở bảng xin quyền VPN thì khởi động Service
        if (requestCode == VPN_REQUEST_CODE && resultCode == RESULT_OK) {
            startService(Intent(this, BridgeVpnService::class.java))
        }
    }
}
