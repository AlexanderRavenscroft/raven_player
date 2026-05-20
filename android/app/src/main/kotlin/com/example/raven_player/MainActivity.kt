package com.example.raven_player

import android.app.Activity
import android.content.Intent
import android.media.MediaMetadataRetriever
import android.net.Uri
import androidx.documentfile.provider.DocumentFile
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import android.provider.DocumentsContract

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
                        else {
                            val list = listDir(Uri.parse(uri))
                            result.success(list)
                        }
                    }
                    "getMetadata" -> {
                        val uri = call.argument<String>("uri")
                        if (uri == null) result.error("ARG", "uri required", null)
                        else getMetadata(Uri.parse(uri), result)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun getMetadata(uri: Uri, result: Result) {
        val retriever = MediaMetadataRetriever()
        try {
            retriever.setDataSource(applicationContext, uri)

            val title    = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE)
            val artist   = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST)
            val album    = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ALBUM)
            val duration = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
                               ?.toLongOrNull()
            val picture  = retriever.embeddedPicture // ByteArray? → Uint8List on Dart side
            result.success(mapOf(
                "title"    to title,
                "artist"   to artist,
                "duration" to duration,
                "cover"    to picture,
            ))
        } catch (e: Exception) {
            result.error("METADATA_ERROR", e.message, null)
        } finally {
            retriever.release()
        }
    }

    // ── SAF ───────────────────────────────────────────────────────────────────

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
        contentResolver.takePersistableUriPermission(
            treeUri,
            Intent.FLAG_GRANT_READ_URI_PERMISSION
        )
        r.success(treeUri.toString())
    }

    
    private fun listDir(uri: Uri): List<Map<String, Any?>> {
        val treeId = DocumentsContract.getTreeDocumentId(uri)
        // If `uri` is a child (from a previous listing), use its own document id.
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
        contentResolver.query(childrenUri, projection, null, null, null)?.use { c ->
            val idIdx   = c.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DOCUMENT_ID)
            val nameIdx = c.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DISPLAY_NAME)
            val mimeIdx = c.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_MIME_TYPE)
            while (c.moveToNext()) {
                val childId = c.getString(idIdx)
                val name    = c.getString(nameIdx)
                val mime    = c.getString(mimeIdx)
                val childUri = DocumentsContract.buildDocumentUriUsingTree(uri, childId)
                val isDir = mime == DocumentsContract.Document.MIME_TYPE_DIR
                out.add(mapOf(
                    "uri"   to childUri.toString(),
                    "name"  to name,
                    "isDir" to isDir,
                    "mime"  to if (isDir) null else mime,
                ))
            }
        }
        return out
    }
}