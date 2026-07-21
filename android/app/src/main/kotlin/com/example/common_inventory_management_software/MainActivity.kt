package com.example.common_inventory_management_software

import android.Manifest
import android.content.ContentValues
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.inventra/pdf_saver"
    private var pendingBytes: ByteArray? = null
    private var pendingFileName: String? = null
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "savePdf") {
                val bytes = call.argument<ByteArray>("bytes")
                val fileName = call.argument<String>("fileName")
                if (bytes != null && fileName != null) {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        val path = savePdfToPublicDirectory(bytes, fileName)
                        if (path != null) {
                            result.success(path)
                        } else {
                            result.error("SAVE_FAILED", "Failed to save PDF", null)
                        }
                    } else {
                        // Check WRITE_EXTERNAL_STORAGE permission for API < 29
                        if (ContextCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE)
                            == PackageManager.PERMISSION_GRANTED) {
                            val path = savePdfToPublicDirectory(bytes, fileName)
                            if (path != null) {
                                result.success(path)
                            } else {
                                result.error("SAVE_FAILED", "Failed to save PDF", null)
                            }
                        } else {
                            pendingBytes = bytes
                            pendingFileName = fileName
                            pendingResult = result
                            ActivityCompat.requestPermissions(
                                this,
                                arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE),
                                100
                            )
                        }
                    }
                } else {
                    result.error("INVALID_ARGUMENTS", "Bytes or fileName is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 100) {
            val result = pendingResult ?: return
            val bytes = pendingBytes ?: return
            val fileName = pendingFileName ?: return
            
            pendingResult = null
            pendingBytes = null
            pendingFileName = null

            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                val path = savePdfToPublicDirectory(bytes, fileName)
                if (path != null) {
                    result.success(path)
                } else {
                    result.error("SAVE_FAILED", "Failed to save PDF after permission granted", null)
                }
            } else {
                result.error("PERMISSION_DENIED", "Storage permission was denied", null)
            }
        }
    }

    private fun savePdfToPublicDirectory(bytes: ByteArray, fileName: String): String? {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val resolver = contentResolver
                val contentValues = ContentValues().apply {
                    put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                    put(MediaStore.MediaColumns.MIME_TYPE, "application/pdf")
                    put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS + "/Inventra")
                }
                val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, contentValues)
                if (uri != null) {
                    resolver.openOutputStream(uri)?.use { outputStream ->
                        outputStream.write(bytes)
                    }
                    "Downloads/Inventra/$fileName"
                } else {
                    null
                }
            } else {
                val downloadDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
                val inventraDir = File(downloadDir, "Inventra")
                if (!inventraDir.exists()) {
                    inventraDir.mkdirs()
                }
                val file = File(inventraDir, fileName)
                FileOutputStream(file).use { outputStream ->
                    outputStream.write(bytes)
                }
                file.absolutePath
            }
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }
}
