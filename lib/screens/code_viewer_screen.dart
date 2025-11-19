import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import '../models/repository.dart';
import '../services/forgejo_api.dart';

class CodeViewerScreen extends StatefulWidget {
  final ForgejoApi api;
  final Repository repository;
  final FileEntry file;

  const CodeViewerScreen({
    super.key,
    required this.api,
    required this.repository,
    required this.file,
  });

  @override
  State<CodeViewerScreen> createState() => _CodeViewerScreenState();
}

class _CodeViewerScreenState extends State<CodeViewerScreen> {
  String _content = '';
  bool _isLoading = true;
  String? _errorMessage;
  bool _showLineNumbers = true;
  bool _isDarkTheme = false;

  @override
  void initState() {
    super.initState();
    _loadFileContent();
  }

  Future<void> _loadFileContent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final content = await widget.api.getFileContent(
        _getOwner(),
        widget.repository.name,
        widget.file.path,
        branch: widget.repository.defaultBranch,
      );

      setState(() {
        _content = content;
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

  String _getLanguage() {
    final ext = widget.file.name.split('.').last.toLowerCase();
    final languageMap = {
      'dart': 'dart',
      'js': 'javascript',
      'ts': 'typescript',
      'jsx': 'javascript',
      'tsx': 'typescript',
      'py': 'python',
      'java': 'java',
      'kt': 'kotlin',
      'swift': 'swift',
      'go': 'go',
      'rs': 'rust',
      'c': 'c',
      'cpp': 'cpp',
      'cc': 'cpp',
      'h': 'c',
      'hpp': 'cpp',
      'cs': 'csharp',
      'rb': 'ruby',
      'php': 'php',
      'sh': 'bash',
      'bash': 'bash',
      'zsh': 'bash',
      'sql': 'sql',
      'json': 'json',
      'yaml': 'yaml',
      'yml': 'yaml',
      'xml': 'xml',
      'html': 'html',
      'css': 'css',
      'scss': 'scss',
      'md': 'markdown',
      'gradle': 'gradle',
      'dockerfile': 'dockerfile',
    };

    return languageMap[ext] ?? 'plaintext';
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.file.name),
        actions: [
          IconButton(
            icon: Icon(_showLineNumbers ? Icons.format_list_numbered : Icons.format_align_left),
            tooltip: 'Toggle line numbers',
            onPressed: () {
              setState(() {
                _showLineNumbers = !_showLineNumbers;
              });
            },
          ),
          IconButton(
            icon: Icon(_isDarkTheme ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle theme',
            onPressed: () {
              setState(() {
                _isDarkTheme = !_isDarkTheme;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy code',
            onPressed: _isLoading ? null : _copyToClipboard,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFileContent,
          ),
        ],
      ),
      body: _buildBody(),
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
              onPressed: _loadFileContent,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Container(
      color: _isDarkTheme ? const Color(0xFF272822) : Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _showLineNumbers
              ? _buildCodeWithLineNumbers()
              : _buildCodeOnly(),
        ),
      ),
    );
  }

  Widget _buildCodeOnly() {
    return HighlightView(
      _content,
      language: _getLanguage(),
      theme: _isDarkTheme ? monokaiSublimeTheme : githubTheme,
      padding: const EdgeInsets.all(16),
      textStyle: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 14,
      ),
    );
  }

  Widget _buildCodeWithLineNumbers() {
    final lines = _content.split('\n');
    final lineNumberWidth = (lines.length.toString().length * 10.0) + 20;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Line numbers
        Container(
          width: lineNumberWidth,
          color: _isDarkTheme ? const Color(0xFF1e1e1e) : Colors.grey.shade100,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(
              lines.length,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 0.5),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    color: _isDarkTheme ? Colors.grey.shade600 : Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Code
        Expanded(
          child: HighlightView(
            _content,
            language: _getLanguage(),
            theme: _isDarkTheme ? monokaiSublimeTheme : githubTheme,
            padding: const EdgeInsets.all(16),
            textStyle: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
