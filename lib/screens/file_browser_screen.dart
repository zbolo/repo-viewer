import 'package:flutter/material.dart';
import '../models/repository.dart';
import '../services/forgejo_api.dart';
import 'code_viewer_screen.dart';

class FileBrowserScreen extends StatefulWidget {
  final ForgejoApi api;
  final Repository repository;
  final String? initialPath;

  const FileBrowserScreen({
    super.key,
    required this.api,
    required this.repository,
    this.initialPath,
  });

  @override
  State<FileBrowserScreen> createState() => _FileBrowserScreenState();
}

class _FileBrowserScreenState extends State<FileBrowserScreen> {
  List<FileEntry> _files = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _currentPath = '';
  final List<String> _pathHistory = [];

  @override
  void initState() {
    super.initState();
    _currentPath = widget.initialPath ?? '';
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final files = await widget.api.getContents(
        _getOwner(),
        widget.repository.name,
        _currentPath.isEmpty ? '' : _currentPath,
        branch: widget.repository.defaultBranch,
      );

      // Sort: directories first, then files, alphabetically
      files.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      setState(() {
        _files = files;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getOwner() {
    final parts = widget.repository.fullName.split('/');
    return parts.first;
  }

  void _navigateToPath(String path) {
    _pathHistory.add(_currentPath);
    setState(() {
      _currentPath = path;
    });
    _loadFiles();
  }

  void _navigateBack() {
    if (_pathHistory.isNotEmpty) {
      setState(() {
        _currentPath = _pathHistory.removeLast();
      });
      _loadFiles();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_pathHistory.isNotEmpty) {
          _navigateBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _navigateBack,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.repository.name, style: const TextStyle(fontSize: 16)),
              if (_currentPath.isNotEmpty)
                Text(
                  _currentPath,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadFiles,
            ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(_errorMessage!, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFiles,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_files.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'This directory is empty',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _files.length,
      itemBuilder: (context, index) {
        final file = _files[index];
        return _FileListItem(
          file: file,
          onTap: () => _onFileTap(file),
        );
      },
    );
  }

  void _onFileTap(FileEntry file) {
    if (file.isDirectory) {
      _navigateToPath(file.path);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CodeViewerScreen(
            api: widget.api,
            repository: widget.repository,
            file: file,
          ),
        ),
      );
    }
  }
}

class _FileListItem extends StatelessWidget {
  final FileEntry file;
  final VoidCallback onTap;

  const _FileListItem({required this.file, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        file.isDirectory ? Icons.folder : _getFileIcon(file.name),
        color: file.isDirectory ? Colors.amber.shade700 : Colors.blue.shade700,
      ),
      title: Text(file.name),
      subtitle: file.isFile ? Text(_formatSize(file.size)) : null,
      trailing: file.isDirectory ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }

  IconData _getFileIcon(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'dart':
      case 'js':
      case 'ts':
      case 'py':
      case 'java':
      case 'kt':
      case 'swift':
      case 'go':
      case 'rs':
      case 'c':
      case 'cpp':
      case 'h':
        return Icons.code;
      case 'json':
      case 'yaml':
      case 'yml':
      case 'xml':
      case 'toml':
        return Icons.settings;
      case 'md':
      case 'txt':
        return Icons.description;
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
      case 'svg':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
