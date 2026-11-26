package com.sgcodexs.menuaim

import android.net.VpnService
import android.content.Intent
import android.os.ParcelFileDescriptor
import java.io.FileInputStream
import java.io.FileOutputStream
import java.nio.ByteBuffer

class BridgeVpnService : VpnService() {
    private var vpnInterface: ParcelFileDescriptor? = null
    private var isAntibanEnabled = true
    private val garenaIps = listOf("103.79.140.", "103.79.141.", "103.79.142.")
    private val reportKeywords = listOf("report", "flag", "screenshot", "cheat")

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent != null && intent.hasExtra("antiban")) {
            isAntibanEnabled = intent.getBooleanExtra("antiban", true)
        }
        if (vpnInterface == null) {
            val builder = Builder()
            builder.setSession("MenuAimAntiban")
            builder.addAddress("10.0.0.2", 32)
            builder.addRoute("0.0.0.0", 0)
            builder.addDnsServer("1.1.1.1")
            builder.setMtu(1500)
            vpnInterface = builder.establish()
            Thread { startPacketInterceptor() }.start()
        }
        return START_STICKY
    }

    private fun startPacketInterceptor() {
        val inputStream = FileInputStream(vpnInterface!!.fileDescriptor)
        val outputStream = FileOutputStream(vpnInterface!!.fileDescriptor)
        val buffer = ByteBuffer.allocate(32767)

        while (true) {
            try {
                val length = inputStream.read(buffer.array())
                if (length > 0) {
                    val packet = buffer.array().copyOf(length)
                    if (isAntibanEnabled && isReportPacket(packet)) continue
                    outputStream.write(packet)
                }
            } catch (e: Exception) { break }
        }
    }

    private fun isReportPacket(packet: ByteArray): Boolean {
        val payload = String(packet, Charsets.ISO_8859_1).lowercase()
        val isToGarena = garenaIps.any { payload.contains(it) }
        if (!isToGarena) return false
        return reportKeywords.any { keyword -> payload.contains(keyword) }
    }

    override fun onDestroy() {
        vpnInterface?.close()
        vpnInterface = null
        super.onDestroy()
    }
}
