package com.example.raven_player

import io.flutter.embedding.android.FlutterActivity
import android.app.Activity
import android.content.Intent
import android.net.Uri
import androidx.documentfile.provider.DocumentFile
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result

class MainActivity : FlutterActivity() {
	private val CHANNEL = "raven/saf"
	private val REQ_PICK_TREE = 4242
	private var pendingResult: Result? = null

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"pickTree" -> pickTree(result)
					"listDir" -> {
						val uri = call.argument<String>("uri")
						if (uri == null) result.error("ARG", "uri required", null)
						else result.success(listDir(Uri.parse(uri)))
					}
					else -> result.notImplemented()
				}
			}
	}

	private fun pickTree(result: Result) {
		pendingResult = result
		val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
			addFlags(
				Intent.FLAG_GRANT_READ_URI_PERMISSION or
				Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION
			)
		}
		startActivityForResult(intent, REQ_PICK_TREE)
	}

	override fun onActivityResult(req: Int, res: Int, data: Intent?) {
		super.onActivityResult(req, res, data)
		if (req != REQ_PICK_TREE) return
		val r = pendingResult ?: return
		pendingResult = null

		if (res != Activity.RESULT_OK || data?.data == null) {
			r.success(null); return
		}
		val treeUri = data.data!!
		// Persist permission across app restarts
		contentResolver.takePersistableUriPermission(
			treeUri,
			Intent.FLAG_GRANT_READ_URI_PERMISSION
		)
		r.success(treeUri.toString())
	}

	private fun listDir(uri: Uri): List<Map<String, Any?>> {
		val doc = DocumentFile.fromTreeUri(this, uri) ?: return emptyList()
		return doc.listFiles().map {
			mapOf(
				"uri" to it.uri.toString(),
				"name" to it.name,
				"isDir" to it.isDirectory,
				"mime" to it.type
			)
		}
	}
}
