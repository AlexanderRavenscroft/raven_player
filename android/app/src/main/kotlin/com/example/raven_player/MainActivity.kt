package com.alexanderavenscroft.raven_player

import android.app.Activity
import android.content.Intent
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.provider.DocumentsContract
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class MainActivity : AudioServiceActivity() {
	companion object {
		private const val CHANNEL = "raven/saf"
		private const val REQUEST_PICK_TREE = 4242
		private const val STATUS_AVAILABLE = "available"
		private const val STATUS_MISSING = "missing"
		private const val STATUS_INACCESSIBLE = "inaccessible"
		private const val METADATA_WORKER_COUNT = 2
	}

	private var pendingResult: Result? = null
	private val metadataExecutor: ExecutorService = Executors.newFixedThreadPool(
		METADATA_WORKER_COUNT
	)

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"pickTree" -> pickTree(result)
					"listDir" -> {
						val uri = uriArgument(call.argument<String>("uri"), result)
							?: return@setMethodCallHandler
						try {
							result.success(listDir(uri))
						} catch (e: Exception) {
							result.error("LIST_DIR_ERROR", e.message, null)
						}
					}
					"getMetadata" -> {
						val uri = uriArgument(call.argument<String>("uri"), result)
							?: return@setMethodCallHandler
						runMetadataTask(result) { getMetadata(uri, result) }
					}
					"getDuration" -> {
						val uri = uriArgument(call.argument<String>("uri"), result)
							?: return@setMethodCallHandler
						runMetadataTask(result) { getDuration(uri, result) }
					}
					"checkAvailability" -> {
						val uris = call.argument<List<String>>("uris")
						if (uris == null) {
							result.error("ARG", "uris required", null)
							return@setMethodCallHandler
						}

						result.success(checkAvailability(uris))
					}
					else -> result.notImplemented()
				}
			}
	}

	override fun onDestroy() {
		metadataExecutor.shutdown()
		super.onDestroy()
	}

	private fun runMetadataTask(result: Result, block: () -> Unit) {
		try {
			metadataExecutor.execute { block() }
		} catch (e: Exception) {
			result.error("METADATA_EXECUTOR_ERROR", e.message, null)
		}
	}

	private fun uriArgument(uri: String?, result: Result): Uri? {
		if (uri == null) {
			result.error("ARG", "uri required", null)
			return null
		}

		return try {
			Uri.parse(uri)
		} catch (e: Exception) {
			result.error("ARG", "invalid uri", e.message)
			null
		}
	}

	private fun getMetadata(uri: Uri, result: Result) {
		val retriever = MediaMetadataRetriever()
		try {
			retriever.setDataSource(applicationContext, uri)
			val title = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE)
			val artist = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST)
			val duration = retriever
				.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
				?.toLongOrNull()
			val picture = retriever.embeddedPicture

			result.success(
				mapOf(
					"title" to title,
					"artist" to artist,
					"duration" to duration,
					"cover" to picture,
				)
			)
		} catch (e: Exception) {
			result.error("METADATA_ERROR", e.message, null)
		} finally {
			retriever.release()
		}
	}

	private fun getDuration(uri: Uri, result: Result) {
		val retriever = MediaMetadataRetriever()
		try {
			retriever.setDataSource(applicationContext, uri)
			val duration = retriever
				.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
				?.toLongOrNull()

			result.success(duration)
		} catch (e: Exception) {
			result.error("DURATION_ERROR", e.message, null)
		} finally {
			retriever.release()
		}
	}

	private fun checkAvailability(uris: List<String>): Map<String, Any?> {
		for (uriString in uris) {
			val uri = try {
				Uri.parse(uriString)
			} catch (_: Exception) {
				return mapOf(
					"status" to STATUS_INACCESSIBLE,
					"uri" to uriString,
				)
			}

			val status = availabilityStatus(uri)
			if (status != STATUS_AVAILABLE) {
				return mapOf(
					"status" to status,
					"uri" to uriString,
				)
			}
		}

		return mapOf(
			"status" to STATUS_AVAILABLE,
			"uri" to null,
		)
	}

	private fun availabilityStatus(uri: Uri): String {
		val documentUri = try {
			val docId = try {
				DocumentsContract.getDocumentId(uri)
			} catch (_: Exception) {
				DocumentsContract.getTreeDocumentId(uri)
			}
			DocumentsContract.buildDocumentUriUsingTree(uri, docId)
		} catch (_: Exception) {
			return STATUS_INACCESSIBLE
		}

		val projection = arrayOf(DocumentsContract.Document.COLUMN_DOCUMENT_ID)
		return try {
			contentResolver.query(documentUri, projection, null, null, null)
				?.use { cursor ->
					if (cursor.moveToFirst()) STATUS_AVAILABLE else STATUS_MISSING
				}
				?: STATUS_MISSING
		} catch (_: SecurityException) {
			STATUS_INACCESSIBLE
		} catch (_: Exception) {
			STATUS_MISSING
		}
	}

	private fun pickTree(result: Result) {
		if (pendingResult != null) {
			result.error("PICKER_ACTIVE", "folder picker already active", null)
			return
		}

		pendingResult = result
		val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
			addFlags(
				Intent.FLAG_GRANT_READ_URI_PERMISSION or
					Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION
			)
		}

		try {
			startActivityForResult(intent, REQUEST_PICK_TREE)
		} catch (e: Exception) {
			pendingResult = null
			result.error("PICK_TREE_ERROR", e.message, null)
		}
	}

	override fun onActivityResult(req: Int, res: Int, data: Intent?) {
		super.onActivityResult(req, res, data)
		if (req != REQUEST_PICK_TREE) return
		val result = pendingResult ?: return
		pendingResult = null

		val treeUri = data?.data
		if (res != Activity.RESULT_OK || treeUri == null) {
			result.success(null)
			return
		}

		try {
			contentResolver.takePersistableUriPermission(
				treeUri,
				Intent.FLAG_GRANT_READ_URI_PERMISSION
			)
			result.success(treeUri.toString())
		} catch (e: SecurityException) {
			result.error("PERMISSION_ERROR", e.message, null)
		}
	}

	private fun listDir(uri: Uri): List<Map<String, Any?>> {
		val treeId = DocumentsContract.getTreeDocumentId(uri)
		val docId = try {
			DocumentsContract.getDocumentId(uri)
		} catch (_: Exception) {
			treeId
		}
		val childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(uri, docId)

		val projection = arrayOf(
			DocumentsContract.Document.COLUMN_DOCUMENT_ID,
			DocumentsContract.Document.COLUMN_DISPLAY_NAME,
			DocumentsContract.Document.COLUMN_MIME_TYPE,
		)

		val out = mutableListOf<Map<String, Any?>>()
		contentResolver.query(childrenUri, projection, null, null, null)?.use { cursor ->
			val idIndex = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DOCUMENT_ID)
			val nameIndex = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DISPLAY_NAME)
			val mimeIndex = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_MIME_TYPE)

			while (cursor.moveToNext()) {
				val childId = cursor.getString(idIndex)
				val name = cursor.getString(nameIndex)
				val mime = cursor.getString(mimeIndex)
				val childUri = DocumentsContract.buildDocumentUriUsingTree(uri, childId)
				val isDir = mime == DocumentsContract.Document.MIME_TYPE_DIR

				out.add(
					mapOf(
						"uri" to childUri.toString(),
						"name" to name,
						"isDir" to isDir,
						"mime" to if (isDir) null else mime,
					)
				)
			}
		}
		return out
	}
}
