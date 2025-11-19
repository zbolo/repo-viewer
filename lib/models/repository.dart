class Repository {
  final int id;
  final String name;
  final String fullName;
  final String description;
  final bool private;
  final String htmlUrl;
  final String defaultBranch;
  final DateTime updatedAt;

  Repository({
    required this.id,
    required this.name,
    required this.fullName,
    required this.description,
    required this.private,
    required this.htmlUrl,
    required this.defaultBranch,
    required this.updatedAt,
  });

  factory Repository.fromJson(Map<String, dynamic> json) {
    return Repository(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      fullName: json['full_name'] ?? '',
      description: json['description'] ?? '',
      private: json['private'] ?? false,
      htmlUrl: json['html_url'] ?? '',
      defaultBranch: json['default_branch'] ?? 'main',
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }
}

class FileEntry {
  final String name;
  final String path;
  final String type; // "file" or "dir"
  final String? downloadUrl;
  final int size;

  FileEntry({
    required this.name,
    required this.path,
    required this.type,
    this.downloadUrl,
    required this.size,
  });

  factory FileEntry.fromJson(Map<String, dynamic> json) {
    return FileEntry(
      name: json['name'] ?? '',
      path: json['path'] ?? '',
      type: json['type'] ?? 'file',
      downloadUrl: json['download_url'],
      size: json['size'] ?? 0,
    );
  }

  bool get isDirectory => type == 'dir';
  bool get isFile => type == 'file';
}
