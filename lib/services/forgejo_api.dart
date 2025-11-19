import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/repository.dart';

class ForgejoApiException implements Exception {
  final String message;
  final int? statusCode;

  ForgejoApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ForgejoApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class ForgejoApi {
  final String baseUrl;
  final String token;

  ForgejoApi({required this.baseUrl, required this.token});

  Map<String, String> get _headers => {
        'Authorization': 'token $token',
        'Content-Type': 'application/json',
      };

  /// Fetch all repositories for the authenticated user
  Future<List<Repository>> getRepositories() async {
    final url = Uri.parse('$baseUrl/api/v1/user/repos');

    try {
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Repository.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw ForgejoApiException('Authentication failed. Please check your token.', 401);
      } else {
        throw ForgejoApiException(
          'Failed to load repositories: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ForgejoApiException) rethrow;
      throw ForgejoApiException('Network error: $e');
    }
  }

  /// Get contents of a directory or file in a repository
  Future<List<FileEntry>> getContents(String owner, String repo, String path, {String? branch}) async {
    final branchParam = branch ?? 'main';
    final encodedPath = Uri.encodeComponent(path);
    final url = Uri.parse('$baseUrl/api/v1/repos/$owner/$repo/contents/$encodedPath?ref=$branchParam');

    try {
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        // API returns array for directories, object for files
        if (data is List) {
          return data.map((json) => FileEntry.fromJson(json)).toList();
        } else {
          return [FileEntry.fromJson(data)];
        }
      } else if (response.statusCode == 404) {
        throw ForgejoApiException('Path not found: $path', 404);
      } else {
        throw ForgejoApiException(
          'Failed to load contents: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ForgejoApiException) rethrow;
      throw ForgejoApiException('Network error: $e');
    }
  }

  /// Get the raw content of a file
  Future<String> getFileContent(String owner, String repo, String path, {String? branch}) async {
    final branchParam = branch ?? 'main';
    final encodedPath = Uri.encodeComponent(path);
    final url = Uri.parse('$baseUrl/api/v1/repos/$owner/$repo/raw/$encodedPath?ref=$branchParam');

    try {
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        return response.body;
      } else if (response.statusCode == 404) {
        throw ForgejoApiException('File not found: $path', 404);
      } else {
        throw ForgejoApiException(
          'Failed to load file: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ForgejoApiException) rethrow;
      throw ForgejoApiException('Network error: $e');
    }
  }

  /// Test the connection with current credentials
  Future<bool> testConnection() async {
    try {
      await getRepositories();
      return true;
    } catch (e) {
      return false;
    }
  }
}
