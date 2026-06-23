import 'package:flutter/foundation.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/docs/v1.dart' as docs;
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:typed_data';

class GoogleDocsService {
  // 1. Paste your Web Client ID here
  static const String _webClientId = '1032356674971-d9ijo8utdsv0iipf40s2e4ub0e7hanep.apps.googleusercontent.com';
  
  static final _scopes = [
    drive.DriveApi.driveScope,
    drive.DriveApi.driveFileScope,
    docs.DocsApi.documentsScope,
  ];

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? _webClientId : null,
    scopes: _scopes,
  );

  static Future<String?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      return account != null ? 'Authenticated User' : null;
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  static Future<http.Client?> _getAuthenticatedClient() async {
    GoogleSignInAccount? account = await _googleSignIn.signInSilently();
    if (account == null) {
      try {
        account = await _googleSignIn.signIn();
      } catch (e) {
        debugPrint('Sign in silently failed: $e');
      }
    }
    
    if (account == null) return null;
    
    return await _googleSignIn.authenticatedClient();
  }

  /// Fetches files from the user's Google Drive. 
  /// Specifically looking for Google Docs (application/vnd.google-apps.document).
  static Future<List<drive.File>> getDriveFiles() async {
    final client = await _getAuthenticatedClient();
    if (client == null) return [];

    try {
      final driveApi = drive.DriveApi(client);
      final response = await driveApi.files.list(
        q: "mimeType='application/vnd.google-apps.document' and trashed=false",
        orderBy: 'modifiedTime desc',
        $fields: 'files(id, name, webViewLink, modifiedTime, iconLink)',
      );
      return response.files ?? [];
    } catch (e) {
      debugPrint('Error fetching drive files: $e');
      return [];
    }
  }

  /// Creates a new Google Doc, optionally inserts text, and returns the WebView link to open it.
  static Future<String?> createNewDocument(String title, {String? content}) async {
    final client = await _getAuthenticatedClient();
    if (client == null) return null;

    try {
      final docsApi = docs.DocsApi(client);
      final document = docs.Document(title: title);
      final createdDoc = await docsApi.documents.create(document);
      
      final docId = createdDoc.documentId;
      if (docId != null) {
        // Insert content if provided
        if (content != null && content.isNotEmpty) {
          final requests = [
            docs.Request(
              insertText: docs.InsertTextRequest(
                location: docs.Location(index: 1),
                text: content,
              ),
            )
          ];
          final updateReq = docs.BatchUpdateDocumentRequest(requests: requests);
          await docsApi.documents.batchUpdate(updateReq, docId);
        }

        // Get the Drive API to fetch the webViewLink
        final driveApi = drive.DriveApi(client);
        final file = await driveApi.files.get(docId, $fields: 'webViewLink') as drive.File;
        return file.webViewLink;
      }
      return null;
    } catch (e) {
      debugPrint('Error creating document: $e');
      return null;
    }
  }

  /// Uploads a local file to Google Drive and converts it to a Google Doc.
  static Future<String?> uploadDocument(Uint8List fileBytes, String fileName) async {
    final client = await _getAuthenticatedClient();
    if (client == null) return null;

    try {
      final driveApi = drive.DriveApi(client);
      
      final media = drive.Media(Stream.value(fileBytes.toList()), fileBytes.length);
      final driveFile = drive.File()
        ..name = fileName
        ..mimeType = 'application/vnd.google-apps.document'; // Auto-convert to Google Doc format

      final createdFile = await driveApi.files.create(
        driveFile,
        uploadMedia: media,
      );
      
      if (createdFile.id != null) {
         final fetchedFile = await driveApi.files.get(createdFile.id!, $fields: 'webViewLink') as drive.File;
         return fetchedFile.webViewLink;
      }
      return null;
    } catch (e) {
      debugPrint('Error uploading document: $e');
      return null;
    }
  }

  static Future<bool> deleteDocument(String documentId) async {
    final client = await _getAuthenticatedClient();
    if (client == null) return false;

    try {
      final driveApi = drive.DriveApi(client);
      await driveApi.files.delete(documentId);
      return true;
    } catch (e) {
      debugPrint('Error deleting document: $e');
      return false;
    }
  }
}
