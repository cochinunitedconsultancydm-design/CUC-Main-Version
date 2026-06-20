import 'package:flutter/foundation.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/docs/v1.dart' as docs;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' as dart_io;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleDocsService {
  // Using the Web Client ID provided by the user.
  // Note: For desktop apps, a Desktop client ID is usually preferred, but Web might work 
  // depending on how the OAuth consent screen is configured.
  static const String _webClientId = 'YOUR_WEB_CLIENT_ID_HERE';
  // Desktop apps require a client secret for the token exchange, even though it's technically a public client.
  // Paste your client secret below:
  static const String _clientSecret = 'YOUR_CLIENT_SECRET_HERE';
  
  static final _scopes = [
    drive.DriveApi.driveScope,
    drive.DriveApi.driveFileScope,
    docs.DocsApi.documentsScope,
  ];

  static AutoRefreshingAuthClient? _authClient;
  static const String _credentialsKey = 'google_docs_credentials';

  static Future<AccessCredentials?> _loadCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_credentialsKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString);
        return AccessCredentials(
          AccessToken(
            json['accessToken']['type'],
            json['accessToken']['data'],
            DateTime.parse(json['accessToken']['expiry']).toUtc(),
          ),
          json['refreshToken'],
          List<String>.from(json['scopes']),
          idToken: json['idToken'],
        );
      }
    } catch (e) {
      debugPrint('Error loading credentials: $e');
    }
    return null;
  }

  static Future<void> _saveCredentials(AccessCredentials credentials) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode({
        'accessToken': {
          'type': credentials.accessToken.type,
          'data': credentials.accessToken.data,
          'expiry': credentials.accessToken.expiry.toUtc().toIso8601String(),
        },
        'refreshToken': credentials.refreshToken,
        'idToken': credentials.idToken,
        'scopes': credentials.scopes,
      });
      await prefs.setString(_credentialsKey, jsonString);
    } catch (e) {
      debugPrint('Error saving credentials: $e');
    }
  }

  static Future<void> _clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_credentialsKey);
  }

  static Future<String?> signIn() async {
    try {
      final clientId = ClientId(_webClientId, _clientSecret);
      
      final savedCreds = await _loadCredentials();
      if (savedCreds != null) {
        _authClient = autoRefreshingClient(clientId, savedCreds, http.Client());
        _authClient!.credentialUpdates.listen(_saveCredentials);
        return 'Authenticated User';
      }

      // This will open a browser, ask the user to sign in, and redirect to a local server to capture the token.
      _authClient = await clientViaUserConsent(
        clientId, 
        _scopes, 
        (url) async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      );
      
      if (_authClient != null) {
        await _saveCredentials(_authClient!.credentials);
        _authClient!.credentialUpdates.listen(_saveCredentials);
      }
      
      return 'Authenticated User';
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    await _clearCredentials();
    _authClient?.close();
    _authClient = null;
  }

  static Future<http.Client?> _getAuthenticatedClient() async {
    if (_authClient == null) {
      await signIn();
    }
    return _authClient;
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
  static Future<String?> uploadDocument(dart_io.File localFile, String fileName) async {
    final client = await _getAuthenticatedClient();
    if (client == null) return null;

    try {
      final driveApi = drive.DriveApi(client);
      
      final media = drive.Media(localFile.openRead(), localFile.lengthSync());
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
